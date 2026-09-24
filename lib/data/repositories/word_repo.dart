import 'package:drift/drift.dart';

import '../db/database.dart';

class WordRepo {
  WordRepo(this._db);

  final AppDatabase _db;

  Future<void> insertAll(List<WordsCompanion> rows) =>
      _db.batch((b) => b.insertAll(_db.words, rows));

  /// A pack's words in source order.
  Future<List<Word>> forPack(String packId) =>
      (_db.select(_db.words)
            ..where((w) => w.packId.equals(packId))
            ..orderBy([(w) => OrderingTerm.asc(w.position)]))
          .get();

  /// A wordlist's words in source order.
  Future<List<Word>> forWordlist(String wordlistId) =>
      (_db.select(_db.words)
            ..where((w) => w.wordlistId.equals(wordlistId))
            ..orderBy([(w) => OrderingTerm.asc(w.position)]))
          .get();

  Future<int> countAll() async {
    final count = _db.words.id.count();
    final row = await (_db.selectOnly(
      _db.words,
    )..addColumns([count])).getSingle();
    return row.read(count)!;
  }
}
