import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/models.dart';
import 'converters.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Wordlists,
    Words,
    Packs,
    Categories,
    PassSessions,
    AppSettings,
    UiState,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// The app's database file (`wordpack.sqlite` in the documents directory).
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'wordpack'));

  /// Bump for every schema change and add a step in [migration]
  /// (`docs/DATA_MODEL.md` §7).
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE UNIQUE INDEX cat_top_key ON categories(key) '
        'WHERE parent_id IS NULL',
      );
      await customStatement(
        'CREATE UNIQUE INDEX cat_sub_key ON categories(parent_id, key) '
        'WHERE parent_id IS NOT NULL',
      );
      await into(appSettings).insert(
        AppSettingsCompanion.insert(
          id: const Value(1),
          defaultDirection: Direction.wd,
          learnedRule: LearnedRule.both,
        ),
      );
      await into(uiState).insert(
        UiStateCompanion.insert(id: const Value(1), expandedNodeIds: const []),
      );
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
