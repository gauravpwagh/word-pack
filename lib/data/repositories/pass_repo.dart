import 'package:drift/drift.dart';

import '../../domain/learning.dart';
import '../../domain/models.dart';
import '../db/database.dart';

/// Unfinished passes: at most one per pack and direction, written after every
/// learning action so a pass survives the app being killed (LRN-9).
class PassRepo {
  PassRepo(this._db);

  final AppDatabase _db;

  Future<PassSession?> get(String packId, Direction direction) =>
      (_db.select(_db.passSessions)..where(
            (s) => s.packId.equals(packId) & s.direction.equalsValue(direction),
          ))
          .getSingleOrNull();

  /// The saved pass as a [PassState] over the pack's [wordIds] (source order).
  Future<PassState?> loadState(
    String packId,
    Direction direction,
    List<String> wordIds,
  ) async {
    final s = await get(packId, direction);
    if (s == null) return null;
    return PassState(
      packId: s.packId,
      direction: s.direction,
      wordIds: wordIds,
      index: s.idx,
      revealed: s.revealed,
      currentRevealed: s.currentRevealed,
      passNumber: s.passNumber,
      startedAt: s.startedAt,
    );
  }

  /// Inserts or replaces the pass for the state's pack and direction.
  Future<void> saveState(
    PassState state, {
    required String id,
    required DateTime now,
  }) => _db
      .into(_db.passSessions)
      .insert(
        PassSessionsCompanion.insert(
          id: id,
          packId: state.packId,
          direction: state.direction,
          idx: state.index,
          revealed: state.revealed,
          currentRevealed: state.currentRevealed,
          passNumber: state.passNumber,
          startedAt: state.startedAt,
          updatedAt: now,
        ),
        onConflict: DoUpdate(
          (_) => PassSessionsCompanion(
            idx: Value(state.index),
            revealed: Value(state.revealed),
            currentRevealed: Value(state.currentRevealed),
            passNumber: Value(state.passNumber),
            startedAt: Value(state.startedAt),
            updatedAt: Value(now),
          ),
          target: [_db.passSessions.packId, _db.passSessions.direction],
        ),
      );

  Future<void> delete(String packId, Direction direction) =>
      (_db.delete(_db.passSessions)..where(
            (s) => s.packId.equals(packId) & s.direction.equalsValue(direction),
          ))
          .go();

  /// Open passes of a wordlist's packs, for Continue and the resume banner.
  Stream<List<PassSession>> watchForWordlist(String wordlistId) {
    final query = _db.select(_db.passSessions).join([
      innerJoin(_db.packs, _db.packs.id.equalsExp(_db.passSessions.packId)),
    ])..where(_db.packs.wordlistId.equals(wordlistId));
    return query.watch().map(
      (rows) => [for (final r in rows) r.readTable(_db.passSessions)],
    );
  }
}
