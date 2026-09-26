import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/db/database.dart';

import '../generated_migrations/schema.dart';
import '../support/test_db.dart';

// Regenerate the helpers after a schema change (docs/DATA_MODEL.md §7):
//   dart run drift_dev make-migrations
//   dart run drift_dev schema generate drift_schemas/default/ test/generated_migrations/
void main() {
  setUpAll(useHostSqlite);

  late SchemaVerifier verifier;
  setUp(() => verifier = SchemaVerifier(GeneratedHelper()));

  test(
    'R-13 a schema v1 database opens and matches the current schema',
    () async {
      final schema = await verifier.schemaAt(1);
      final db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, 1);
      await db.close();
    },
  );

  test('v1 → v2 keeps the data and adds the D-34 columns', () async {
    final schema = await verifier.schemaAt(1);
    final old = schema.rawDatabase;
    old.execute(
      'INSERT INTO app_settings (id, pack_size, default_direction, '
      'learned_rule, show_pos, demote_on_reveal, theme) '
      "VALUES (1, 20, 'dw', 'either', 0, 1, 'dark')",
    );
    old.execute(
      'INSERT INTO ui_state (id, expanded_node_ids, viewer_mode, '
      "tree_panel_open) VALUES (1, '[]', 'list', 0)",
    );
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    final settings = await db.select(db.appSettings).getSingle();
    expect(settings.packSize, 20);
    expect(settings.theme, 'dark');
    expect(settings.studyButtons, isTrue);
    final ui = await db.select(db.uiState).getSingle();
    expect(ui.viewerMode, 'list');
    expect(ui.gestureHintPasses, 0);
    await db.close();
  });

  test(
    'a fresh database is created at the current version with seed rows',
    () async {
      final db = memoryDb();
      addTearDown(db.close);
      expect(db.schemaVersion, 2);
      final settings = await db.select(db.appSettings).getSingle();
      expect(settings.packSize, 30);
      expect((await db.select(db.uiState).getSingle()).viewerMode, 'card');
      // The case-insensitive uniqueness per level is enforced by the database.
      final indexes = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
          .get();
      expect([
        for (final r in indexes) r.read<String>('name'),
      ], containsAll(['cat_top_key', 'cat_sub_key', 'words_pack_id']));
    },
  );
}
