# Data model

Local SQLite through **drift** (`lib/data/db/`). IDs are UUID v4 strings (package `uuid`) so backups from different devices never collide. Timestamps are stored as drift `DateTimeColumn` (UTC), written as ISO-8601 text (`build.yaml`) so they read back in UTC. Enable foreign keys in `MigrationStrategy.beforeOpen` (`PRAGMA foreign_keys = ON`).

Dart field names are camelCase; drift maps them to snake_case columns automatically.

## 1. Overview

```
Wordlists 1──< Words >──0..1 Categories (top level)
    │            └──0..1 Categories (subcategory, parent = the above)
    └──< Packs 1──< Words          (word.packId)
          └──< PassSessions  (0..2, one per direction)
AppSettings (single row)   UiState (single row)
```

## 2. Tables (drift definitions, abridged)

```dart
class Wordlists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get sourceFilename => text()();
  TextColumn get sourceFormat => text()();            // 'dash' | 'columns'
  IntColumn  get wordCount => integer()();
  DateTimeColumn get importedAt => dateTime()();
  @override Set<Column> get primaryKey => {id};
}

class Words extends Table {
  TextColumn get id => text()();
  TextColumn get wordlistId => text().references(Wordlists, #id, onDelete: KeyAction.cascade)();
  IntColumn  get position => integer()();              // 0-based order after dedupe
  TextColumn get term => text()();
  TextColumn get pos => text().nullable()();            // canonical key: noun, adjective, …, other
  TextColumn get posRaw => text().nullable()();
  TextColumn get definition => text()();
  TextColumn get packId => text().references(Packs, #id)();
  TextColumn get tone => text().nullable()();           // positive | negative | neutral
  BoolColumn get counterIntuitive => boolean().withDefault(const Constant(false))();
  BoolColumn get multipleMeanings => boolean().withDefault(const Constant(false))();
  TextColumn get categoryId => text().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  TextColumn get subcategoryId => text().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  BoolColumn get masteredWd => boolean().withDefault(const Constant(false))();
  BoolColumn get masteredDw => boolean().withDefault(const Constant(false))();
  IntColumn  get revealCountWd => integer().withDefault(const Constant(0))();
  IntColumn  get revealCountDw => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  DateTimeColumn get lastRevealedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  @override Set<Column> get primaryKey => {id};
  @override List<Set<Column>> get uniqueKeys => [{wordlistId, position}];
}

class Packs extends Table {
  TextColumn get id => text()();
  TextColumn get wordlistId => text().references(Wordlists, #id, onDelete: KeyAction.cascade)();
  IntColumn  get number => integer()();                // 1-based
  TextColumn get masteryWd => textEnum<Mastery>()();
  TextColumn get masteryDw => textEnum<Mastery>()();
  IntColumn  get passesWd => integer().withDefault(const Constant(0))();
  IntColumn  get passesDw => integer().withDefault(const Constant(0))();
  IntColumn  get cleanPassesWd => integer().withDefault(const Constant(0))();
  IntColumn  get cleanPassesDw => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPassAtWd => dateTime().nullable()();
  DateTimeColumn get lastPassAtDw => dateTime().nullable()();
  DateTimeColumn get masteredAtWd => dateTime().nullable()();
  DateTimeColumn get masteredAtDw => dateTime().nullable()();
  TextColumn get lastDirection => textEnum<Direction>().nullable()();
  DateTimeColumn get learnedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  @override Set<Column> get primaryKey => {id};
  @override List<Set<Column>> get uniqueKeys => [{wordlistId, number}];
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();   // display spelling (first entered)
  TextColumn get key => text()();                                // trimmed, spaces collapsed, lower-cased
  TextColumn get parentId => text().nullable().references(Categories, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt => dateTime()();
  @override Set<Column> get primaryKey => {id};
}
// plus in migration: CREATE UNIQUE INDEX cat_sub_key ON categories(parent_id, key) WHERE parent_id IS NOT NULL;
//                    CREATE UNIQUE INDEX cat_top_key ON categories(key) WHERE parent_id IS NULL;

class PassSessions extends Table {
  TextColumn get id => text()();
  TextColumn get packId => text().references(Packs, #id, onDelete: KeyAction.cascade)();
  TextColumn get direction => textEnum<Direction>()();
  IntColumn  get idx => integer()();
  TextColumn get revealed => text().map(const StringListConverter())();   // JSON list of word ids
  BoolColumn get currentRevealed => boolean()();
  IntColumn  get passNumber => integer()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override Set<Column> get primaryKey => {id};
  @override List<Set<Column>> get uniqueKeys => [{packId, direction}];
}

class AppSettings extends Table {   // single row, id = 1
  IntColumn get id => integer()();
  IntColumn get packSize => integer().withDefault(const Constant(30))();          // 5..100
  TextColumn get defaultDirection => textEnum<Direction>()();                      // wd
  TextColumn get learnedRule => textEnum<LearnedRule>()();                         // both
  BoolColumn get showPos => boolean().withDefault(const Constant(true))();
  BoolColumn get demoteOnReveal => boolean().withDefault(const Constant(false))();
  TextColumn get theme => text().withDefault(const Constant('system'))();         // light | dark | system
  @override Set<Column> get primaryKey => {id};
}

class UiState extends Table {       // single row, id = 1
  IntColumn get id => integer()();
  TextColumn get expandedNodeIds => text().map(const StringListConverter())();
  TextColumn get selectedNodeId => text().nullable()();
  TextColumn get viewerMode => text().withDefault(const Constant('card'))();      // card | list
  BoolColumn get treePanelOpen => boolean().withDefault(const Constant(true))();
  @override Set<Column> get primaryKey => {id};
}
```

Indexes: `words(pack_id)`, `words(category_id)`, `words(subcategory_id)`, `words(tone)`, `words(term)`, `packs(wordlist_id)`.

Pack words = `Words` with that `packId`, ordered by `position`. Pack status is **not stored** — derived (`LEARNING_LOGIC.md` §2). Seed `AppSettings` and `UiState` rows in `onCreate`.

## 3. Invariants (enforced in repositories/services, covered by tests)

1. Every word has exactly one pack in the same wordlist; pack words are consecutive by position.
2. Pack numbers per wordlist are 1..k; each pack has 1..packSize words (always true, because changing the size rebuilds every pack).
3. `subcategoryId` set ⇒ `categoryId` set and the subcategory's `parentId == categoryId`.
4. Category depth ≤ 2.
5. Category writes throw `WordNotLearnedException` unless the word's pack status is `learned`. Tone and trait writes are allowed on any word (D-32).
6. At most one pass session per (pack, direction).
7. Every multi-row change runs in one `db.transaction(...)`.

## 4. Derived values

| Value | How |
|---|---|
| Pack status | `packStatus(masteryWd, masteryDw, settings.learnedRule, hasOpenPass: …)` |
| Word learned | its pack's status == learned |
| Wordlist progress | learned packs / packs, learned words / words |
| Tree counts | `GROUP BY category_id, subcategory_id` per wordlist + tone/trait counts, exposed as drift `watch()` streams so the tree updates live |
| Pack label | `Pack 1 · abbey – advent` (first and last term) |

## 5. Category delete / merge

- Delete subcategory → words' `subcategoryId` set null (FK).
- Delete category → subcategories cascade; words' `categoryId` and `subcategoryId` set null.
- Merge A into B (same level) → reassign words; merge A's subcategories into B's by `key`, move the rest; delete A. One transaction.

## 6. Backup file (P1)

`wordpack-backup-2026-09-24.json`:

```json
{ "app": "wordpack", "schemaVersion": 1, "exportedAt": "2026-09-24T10:00:00Z",
  "settings": {}, "categories": [], "wordlists": [], "packs": [], "words": [], "passSessions": [] }
```

Restore validates `app` and `schemaVersion`, then replaces all tables in one transaction. Export via `share_plus` (mobile) or `file_selector` save dialog (desktop).

## 7. Migrations

Bump `schemaVersion` in the drift database for every schema change and add a step in `MigrationStrategy.onUpgrade`; keep drift's schema dumps (`drift_dev schema dump`) in `drift_schemas/` and add generated migration tests.
