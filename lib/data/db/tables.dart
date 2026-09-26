import 'package:drift/drift.dart';

import '../../domain/models.dart';
import 'converters.dart';

// Tables from docs/DATA_MODEL.md §2. Dart names are camelCase; drift maps
// them to snake_case columns. Ids are UUID v4 strings, times are UTC.

class Wordlists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get sourceFilename => text()();

  /// `dash` | `columns` (ImportFormat.name).
  TextColumn get sourceFormat => text()();
  IntColumn get wordCount => integer()();
  DateTimeColumn get importedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'words_pack_id', columns: {#packId})
@TableIndex(name: 'words_category_id', columns: {#categoryId})
@TableIndex(name: 'words_subcategory_id', columns: {#subcategoryId})
@TableIndex(name: 'words_tone', columns: {#tone})
@TableIndex(name: 'words_term', columns: {#term})
class Words extends Table {
  TextColumn get id => text()();
  TextColumn get wordlistId =>
      text().references(Wordlists, #id, onDelete: KeyAction.cascade)();

  /// 0-based order after de-duplication.
  IntColumn get position => integer()();
  TextColumn get term => text()();

  /// Canonical key (`noun`, `adjective`, …, `other`) or null.
  TextColumn get pos => text().nullable()();
  TextColumn get posRaw => text().nullable()();
  TextColumn get definition => text()();
  TextColumn get packId => text().references(Packs, #id)();
  TextColumn get tone => textEnum<Tone>().nullable()();
  BoolColumn get counterIntuitive =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get multipleMeanings =>
      boolean().withDefault(const Constant(false))();
  TextColumn get categoryId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get subcategoryId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  BoolColumn get masteredWd => boolean().withDefault(const Constant(false))();
  BoolColumn get masteredDw => boolean().withDefault(const Constant(false))();
  IntColumn get revealCountWd => integer().withDefault(const Constant(0))();
  IntColumn get revealCountDw => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  DateTimeColumn get lastRevealedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {wordlistId, position},
  ];
}

@TableIndex(name: 'packs_wordlist_id', columns: {#wordlistId})
class Packs extends Table {
  TextColumn get id => text()();
  TextColumn get wordlistId =>
      text().references(Wordlists, #id, onDelete: KeyAction.cascade)();

  /// 1-based.
  IntColumn get number => integer()();
  TextColumn get masteryWd => textEnum<Mastery>()();
  TextColumn get masteryDw => textEnum<Mastery>()();
  IntColumn get passesWd => integer().withDefault(const Constant(0))();
  IntColumn get passesDw => integer().withDefault(const Constant(0))();
  IntColumn get cleanPassesWd => integer().withDefault(const Constant(0))();
  IntColumn get cleanPassesDw => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPassAtWd => dateTime().nullable()();
  DateTimeColumn get lastPassAtDw => dateTime().nullable()();
  DateTimeColumn get masteredAtWd => dateTime().nullable()();
  DateTimeColumn get masteredAtDw => dateTime().nullable()();
  TextColumn get lastDirection => textEnum<Direction>().nullable()();
  DateTimeColumn get learnedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {wordlistId, number},
  ];
}

/// Shared across wordlists; a row with [parentId] is a subcategory. The
/// case-insensitive uniqueness per level is enforced by partial indexes
/// created in the migration (`cat_top_key`, `cat_sub_key`).
class Categories extends Table {
  TextColumn get id => text()();

  /// Display spelling (first entered).
  TextColumn get name => text().withLength(min: 1, max: 80)();

  /// Trimmed, spaces collapsed, lower-cased.
  TextColumn get key => text()();
  TextColumn get parentId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.cascade,
  )();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PassSessions extends Table {
  TextColumn get id => text()();
  TextColumn get packId =>
      text().references(Packs, #id, onDelete: KeyAction.cascade)();
  TextColumn get direction => textEnum<Direction>()();
  IntColumn get idx => integer()();

  /// Word ids peeked this pass.
  TextColumn get revealed => text().map(const StringListConverter())();
  BoolColumn get currentRevealed => boolean()();
  IntColumn get passNumber => integer()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {packId, direction},
  ];
}

/// Single row, id = 1.
class AppSettings extends Table {
  IntColumn get id => integer()();
  IntColumn get packSize => integer().withDefault(const Constant(30))();
  TextColumn get defaultDirection => textEnum<Direction>()();
  TextColumn get learnedRule => textEnum<LearnedRule>()();
  BoolColumn get showPos => boolean().withDefault(const Constant(true))();
  BoolColumn get demoteOnReveal =>
      boolean().withDefault(const Constant(false))();

  /// `light` | `dark` | `system`.
  TextColumn get theme => text().withDefault(const Constant('system'))();

  /// Show / Next / Previous buttons under the study card; off = tap and
  /// swipe only (D-34). Schema v2.
  BoolColumn get studyButtons => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Single row, id = 1.
class UiState extends Table {
  IntColumn get id => integer()();
  TextColumn get expandedNodeIds => text().map(const StringListConverter())();
  TextColumn get selectedNodeId => text().nullable()();

  /// `card` | `list`.
  TextColumn get viewerMode => text().withDefault(const Constant('card'))();
  BoolColumn get treePanelOpen => boolean().withDefault(const Constant(true))();

  /// Passes finished with the study buttons off; the gesture hint shows for
  /// the first three (D-34). Schema v2.
  IntColumn get gestureHintPasses => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
