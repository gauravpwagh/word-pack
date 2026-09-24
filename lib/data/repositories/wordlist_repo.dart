import 'package:drift/drift.dart';

import '../db/database.dart';

class WordlistRepo {
  WordlistRepo(this._db);

  final AppDatabase _db;

  /// Most recently imported first.
  Stream<List<Wordlist>> watchAll() => (_db.select(
    _db.wordlists,
  )..orderBy([(w) => OrderingTerm.desc(w.importedAt)])).watch();

  Future<Wordlist?> get(String id) => (_db.select(
    _db.wordlists,
  )..where((w) => w.id.equals(id))).getSingleOrNull();

  Stream<Wordlist?> watch(String id) => (_db.select(
    _db.wordlists,
  )..where((w) => w.id.equals(id))).watchSingleOrNull();

  Future<void> insert(WordlistsCompanion row) =>
      _db.into(_db.wordlists).insert(row);

  Future<void> rename(String id, String name) =>
      (_db.update(_db.wordlists)..where((w) => w.id.equals(id))).write(
        WordlistsCompanion(name: Value(name)),
      );

  /// Words, packs and passes go with it (foreign-key cascades); categories are
  /// shared and stay.
  Future<void> delete(String id) =>
      (_db.delete(_db.wordlists)..where((w) => w.id.equals(id))).go();
}
