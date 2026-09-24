import 'package:drift/drift.dart';

import '../../domain/learning.dart';
import '../../domain/models.dart';
import '../db/database.dart';

/// A pack with what its tile and the Continue button need.
class PackRow {
  const PackRow({
    required this.pack,
    required this.firstTerm,
    required this.lastTerm,
    required this.wordCount,
    required this.openDirections,
  });

  final Pack pack;
  final String firstTerm;
  final String lastTerm;
  final int wordCount;

  /// Directions with an unfinished pass.
  final Set<Direction> openDirections;

  PackProgress get progress =>
      PackProgress(wd: pack.masteryWd, dw: pack.masteryDw);

  PackStatus status(LearnedRule rule) =>
      progress.status(rule, hasOpenPass: openDirections.isNotEmpty);
}

class PackRepo {
  PackRepo(this._db);

  final AppDatabase _db;

  Future<void> insertAll(List<PacksCompanion> rows) =>
      _db.batch((b) => b.insertAll(_db.packs, rows));

  Future<Pack?> get(String id) =>
      (_db.select(_db.packs)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<List<Pack>> forWordlist(String wordlistId) =>
      (_db.select(_db.packs)
            ..where((p) => p.wordlistId.equals(wordlistId))
            ..orderBy([(p) => OrderingTerm.asc(p.number)]))
          .get();

  /// The wordlist's packs in number order, updated live.
  Stream<List<PackRow>> watchRows(String wordlistId) {
    final query = _db.customSelect(
      '''
      SELECT p.*,
        (SELECT term FROM words w WHERE w.pack_id = p.id
           ORDER BY w.position ASC LIMIT 1) AS first_term,
        (SELECT term FROM words w WHERE w.pack_id = p.id
           ORDER BY w.position DESC LIMIT 1) AS last_term,
        (SELECT COUNT(*) FROM words w WHERE w.pack_id = p.id) AS word_count,
        (SELECT group_concat(s.direction) FROM pass_sessions s
           WHERE s.pack_id = p.id) AS open_directions
      FROM packs p
      WHERE p.wordlist_id = ?
      ORDER BY p.number ASC
      ''',
      variables: [Variable.withString(wordlistId)],
      readsFrom: {_db.packs, _db.words, _db.passSessions},
    );
    return query.watch().asyncMap((rows) async {
      return [
        for (final row in rows)
          PackRow(
            pack: await _db.packs.mapFromRow(row),
            firstTerm: row.read<String>('first_term'),
            lastTerm: row.read<String>('last_term'),
            wordCount: row.read<int>('word_count'),
            openDirections: {
              for (final d
                  in (row.readNullable<String>('open_directions') ?? '')
                      .split(',')
                      .where((s) => s.isNotEmpty))
                Direction.values.byName(d),
            },
          ),
      ];
    });
  }
}
