import 'package:drift/drift.dart';

import '../data/db/database.dart';
import '../data/repositories/pack_repo.dart';
import '../data/repositories/pass_repo.dart';
import '../data/repositories/settings_repo.dart';
import '../data/repositories/word_repo.dart';
import '../domain/clock.dart';
import '../domain/ids.dart';
import '../domain/learning.dart' as learning;
import '../domain/learning.dart'
    show LearningEvent, PassCompleted, PassState, PassStep, Revealed;
import '../domain/models.dart';

/// What the pass summary shows (`docs/LEARNING_LOGIC.md` §3).
class PassResult {
  const PassResult({
    required this.packId,
    required this.direction,
    required this.clean,
    required this.peekedWordIds,
    required this.status,
    required this.becameLearned,
  });

  final String packId;
  final Direction direction;
  final bool clean;

  /// In the order they were peeked.
  final List<String> peekedWordIds;
  final PackStatus status;

  /// True only for the pass that first made the pack Learned.
  final bool becameLearned;
}

/// The outcome of one learning action: the pass as it is now (null once it
/// is over) and, when it just ended, its result.
class PassUpdate {
  const PassUpdate(this.pass, [this.result]);

  final PassState? pass;
  final PassResult? result;
}

class NoOpenPassException implements Exception {
  const NoOpenPassException(this.packId, this.direction);

  final String packId;
  final Direction direction;

  @override
  String toString() => 'NoOpenPassException($packId, ${direction.name})';
}

class PackNotFoundException implements Exception {
  const PackNotFoundException(this.packId);

  final String packId;

  @override
  String toString() => 'PackNotFoundException($packId)';
}

/// One method per learning action, each in one transaction: load the pass,
/// run the pure reducer (`domain/learning.dart`), apply its events to words
/// and pack, save or delete the pass.
class LearningService {
  LearningService({
    required AppDatabase db,
    required Clock clock,
    required IdGenerator ids,
  }) : _db = db,
       _clock = clock,
       _ids = ids,
       _packs = PackRepo(db),
       _words = WordRepo(db),
       _passes = PassRepo(db),
       _settings = SettingsRepo(db);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;
  final PackRepo _packs;
  final WordRepo _words;
  final PassRepo _passes;
  final SettingsRepo _settings;

  /// Resumes the open pass in [direction], or starts one.
  Future<PassState> open(String packId, Direction direction) =>
      _db.transaction(() async {
        final wordIds = await _wordIds(packId);
        final existing = await _passes.loadState(packId, direction, wordIds);
        if (existing != null) {
          await _remember(packId, direction);
          return existing;
        }
        return _start(packId, direction, wordIds);
      });

  /// Drops the open pass in [direction] and starts a new one (Repeat pack,
  /// Review this pack).
  Future<PassState> restart(String packId, Direction direction) =>
      _db.transaction(() async {
        final wordIds = await _wordIds(packId);
        await _passes.delete(packId, direction);
        return _start(packId, direction, wordIds);
      });

  /// Switching direction mid-pass: the current pass is abandoned (its
  /// reveals stay recorded) and a new pass starts in [to].
  Future<PassState> switchDirection(
    String packId, {
    required Direction from,
    required Direction to,
  }) => _db.transaction(() async {
    final wordIds = await _wordIds(packId);
    await _passes.delete(packId, from);
    await _passes.delete(packId, to);
    return _start(packId, to, wordIds);
  });

  Future<PassUpdate> show(String packId, Direction d) =>
      _act(packId, d, learning.show);

  Future<PassUpdate> next(String packId, Direction d) =>
      _act(packId, d, learning.next);

  Future<PassUpdate> previous(String packId, Direction d) =>
      _act(packId, d, learning.previous);

  // -------------------------------------------------------------------------

  Future<List<String>> _wordIds(String packId) async {
    if (await _packs.get(packId) == null) throw PackNotFoundException(packId);
    return [for (final w in await _words.forPack(packId)) w.id];
  }

  Future<PassState> _start(
    String packId,
    Direction direction,
    List<String> wordIds,
  ) async {
    final now = _clock.now();
    final pack = (await _packs.get(packId))!;
    final state = learning.startPass(
      packId: packId,
      direction: direction,
      wordIds: wordIds,
      passNumber: _passCount(pack, direction) + 1,
      now: now,
    );
    await _passes.saveState(state, id: _ids.newId(), now: now);
    await _remember(packId, direction);
    await _seen(state.currentWordId, now);
    return state;
  }

  Future<void> _remember(String packId, Direction direction) =>
      (_db.update(_db.packs)..where((p) => p.id.equals(packId))).write(
        PacksCompanion(lastDirection: Value(direction)),
      );

  Future<void> _seen(String wordId, DateTime now) =>
      (_db.update(_db.words)..where((w) => w.id.equals(wordId))).write(
        WordsCompanion(lastSeenAt: Value(now)),
      );

  Future<PassUpdate> _act(
    String packId,
    Direction d,
    PassStep Function(PassState) reduce,
  ) => _db.transaction(() async {
    final wordIds = await _wordIds(packId);
    final state = await _passes.loadState(packId, d, wordIds);
    if (state == null) throw NoOpenPassException(packId, d);

    final now = _clock.now();
    final (after, events) = reduce(state);
    PassResult? result;
    for (final e in events) {
      result = await _apply(packId, d, e, now) ?? result;
    }
    if (after == null) {
      await _passes.delete(packId, d);
    } else {
      await _passes.saveState(after, id: _ids.newId(), now: now);
      if (after.index != state.index) await _seen(after.currentWordId, now);
    }
    return PassUpdate(after, result);
  });

  /// Writes one event (the table in `LEARNING_LOGIC.md` §2). Returns the pass
  /// result for [PassCompleted].
  Future<PassResult?> _apply(
    String packId,
    Direction d,
    LearningEvent event,
    DateTime now,
  ) async {
    final settings = await _settings.get();
    final pack = (await _packs.get(packId))!;
    final before = learning.PackProgress(
      wd: pack.masteryWd,
      dw: pack.masteryDw,
    );
    final after = learning.applyEvent(
      before,
      d,
      event,
      demoteOnReveal: settings.demoteOnReveal,
    );

    switch (event) {
      case Revealed(:final wordId):
        final demotes = learning.revealDemotes(
          before.of(d),
          demoteOnReveal: settings.demoteOnReveal,
        );
        final word = await (_db.select(
          _db.words,
        )..where((w) => w.id.equals(wordId))).getSingle();
        final seen = WordsCompanion(
          lastRevealedAt: Value(now),
          lastSeenAt: Value(now),
          updatedAt: Value(now),
        );
        await (_db.update(_db.words)..where((w) => w.id.equals(wordId))).write(
          d == Direction.wd
              ? seen.copyWith(
                  revealCountWd: Value(word.revealCountWd + 1),
                  masteredWd: demotes
                      ? const Value(false)
                      : const Value.absent(),
                )
              : seen.copyWith(
                  revealCountDw: Value(word.revealCountDw + 1),
                  masteredDw: demotes
                      ? const Value(false)
                      : const Value.absent(),
                ),
        );
        await _writePack(packId, d, after.of(d), pack: pack, now: now);
        return null;

      case PassCompleted(:final clean, :final revealedWordIds):
        if (clean) {
          await (_db.update(
            _db.words,
          )..where((w) => w.packId.equals(packId))).write(
            d == Direction.wd
                ? WordsCompanion(
                    masteredWd: const Value(true),
                    updatedAt: Value(now),
                  )
                : WordsCompanion(
                    masteredDw: const Value(true),
                    updatedAt: Value(now),
                  ),
          );
        }
        final wasLearned = learning.isLearned(
          before.wd,
          before.dw,
          settings.learnedRule,
        );
        final isLearned = learning.isLearned(
          after.wd,
          after.dw,
          settings.learnedRule,
        );
        final becameLearned = isLearned && !wasLearned;
        await _writePack(
          packId,
          d,
          after.of(d),
          pack: pack,
          now: now,
          passCompleted: true,
          clean: clean,
          learnedAt: becameLearned && pack.learnedAt == null ? now : null,
        );
        final otherOpen = await _passes.get(packId, d.other) != null;
        return PassResult(
          packId: packId,
          direction: d,
          clean: clean,
          peekedWordIds: revealedWordIds,
          status: after.status(settings.learnedRule, hasOpenPass: otherOpen),
          becameLearned: becameLearned,
        );
    }
  }

  Future<void> _writePack(
    String packId,
    Direction d,
    Mastery mastery, {
    required Pack pack,
    required DateTime now,
    bool passCompleted = false,
    bool clean = false,
    DateTime? learnedAt,
  }) {
    final newlyMastered =
        mastery == Mastery.mastered &&
        (d == Direction.wd ? pack.masteredAtWd : pack.masteredAtDw) == null;
    final passes = _passCount(pack, d) + (passCompleted ? 1 : 0);
    final cleanPasses =
        (d == Direction.wd ? pack.cleanPassesWd : pack.cleanPassesDw) +
        (passCompleted && clean ? 1 : 0);
    final companion = d == Direction.wd
        ? PacksCompanion(
            masteryWd: Value(mastery),
            passesWd: Value(passes),
            cleanPassesWd: Value(cleanPasses),
            lastPassAtWd: passCompleted ? Value(now) : const Value.absent(),
            masteredAtWd: newlyMastered ? Value(now) : const Value.absent(),
          )
        : PacksCompanion(
            masteryDw: Value(mastery),
            passesDw: Value(passes),
            cleanPassesDw: Value(cleanPasses),
            lastPassAtDw: passCompleted ? Value(now) : const Value.absent(),
            masteredAtDw: newlyMastered ? Value(now) : const Value.absent(),
          );
    return (_db.update(_db.packs)..where((p) => p.id.equals(packId))).write(
      learnedAt == null
          ? companion
          : companion.copyWith(learnedAt: Value(learnedAt)),
    );
  }

  static int _passCount(Pack pack, Direction d) =>
      d == Direction.wd ? pack.passesWd : pack.passesDw;
}
