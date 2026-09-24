/// The learning core: pass state machine, mastery rules, derived pack status
/// and the "Continue" target (`docs/LEARNING_LOGIC.md`). Pure Dart; time is
/// passed in.
library;

import 'models.dart';

// ---------------------------------------------------------------------------
// Pack status (§2)
// ---------------------------------------------------------------------------

/// Whether [rule] is satisfied by the two directions' mastery.
bool isLearned(Mastery wd, Mastery dw, LearnedRule rule) {
  final w = wd == Mastery.mastered;
  final d = dw == Mastery.mastered;
  return switch (rule) {
    LearnedRule.both => w && d,
    LearnedRule.either => w || d,
    LearnedRule.wdOnly => w,
    LearnedRule.dwOnly => d,
  };
}

/// Derived pack status; never stored.
PackStatus packStatus(
  Mastery wd,
  Mastery dw,
  LearnedRule rule, {
  required bool hasOpenPass,
}) {
  if (isLearned(wd, dw, rule)) return PackStatus.learned;
  if (wd == Mastery.unseen && dw == Mastery.unseen && !hasOpenPass) {
    return PackStatus.newPack;
  }
  return PackStatus.learning;
}

/// Mastery of one pack in both directions.
final class PackProgress {
  const PackProgress({this.wd = Mastery.unseen, this.dw = Mastery.unseen});

  final Mastery wd;
  final Mastery dw;

  Mastery of(Direction d) => d == Direction.wd ? wd : dw;

  PackProgress withMastery(Direction d, Mastery m) => d == Direction.wd
      ? PackProgress(wd: m, dw: dw)
      : PackProgress(wd: wd, dw: m);

  PackStatus status(LearnedRule rule, {required bool hasOpenPass}) =>
      packStatus(wd, dw, rule, hasOpenPass: hasOpenPass);

  @override
  bool operator ==(Object other) =>
      other is PackProgress && other.wd == wd && other.dw == dw;

  @override
  int get hashCode => Object.hash(wd, dw);

  @override
  String toString() => 'PackProgress(wd: ${wd.name}, dw: ${dw.name})';
}

/// Whether a reveal on a pack at [current] mastery demotes it (review with
/// the "peeks during review demote the pack" setting on).
bool revealDemotes(Mastery current, {required bool demoteOnReveal}) =>
    current == Mastery.mastered && demoteOnReveal;

/// Pack mastery after a Show (§2 table).
Mastery masteryAfterReveal(Mastery current, {required bool demoteOnReveal}) {
  if (current == Mastery.mastered && !demoteOnReveal) return Mastery.mastered;
  return Mastery.learning;
}

/// Pack mastery after a completed pass. A pass with peeks never demotes a
/// mastered pack by itself (D-15); demotion happens on the reveal.
Mastery masteryAfterPass(Mastery current, {required bool clean}) {
  if (clean || current == Mastery.mastered) return Mastery.mastered;
  return Mastery.learning;
}

/// Applies one [LearningEvent] of a pass in direction [d] to [progress].
PackProgress applyEvent(
  PackProgress progress,
  Direction d,
  LearningEvent event, {
  required bool demoteOnReveal,
}) {
  final current = progress.of(d);
  final next = switch (event) {
    Revealed() => masteryAfterReveal(current, demoteOnReveal: demoteOnReveal),
    PassCompleted(:final clean) => masteryAfterPass(current, clean: clean),
  };
  return progress.withMastery(d, next);
}

// ---------------------------------------------------------------------------
// Pass state machine (§3)
// ---------------------------------------------------------------------------

sealed class LearningEvent {
  const LearningEvent();
}

/// Show was pressed on a card for the first time this pass.
final class Revealed extends LearningEvent {
  const Revealed(this.wordId);

  final String wordId;

  @override
  bool operator ==(Object other) => other is Revealed && other.wordId == wordId;

  @override
  int get hashCode => wordId.hashCode;

  @override
  String toString() => 'Revealed($wordId)';
}

/// The pass reached its end. [clean] = no reveals.
final class PassCompleted extends LearningEvent {
  const PassCompleted({required this.clean, required this.revealedWordIds});

  final bool clean;
  final List<String> revealedWordIds;

  @override
  bool operator ==(Object other) =>
      other is PassCompleted &&
      other.clean == clean &&
      _listEquals(other.revealedWordIds, revealedWordIds);

  @override
  int get hashCode => Object.hash(clean, Object.hashAll(revealedWordIds));

  @override
  String toString() => 'PassCompleted(clean: $clean, $revealedWordIds)';
}

/// One run through a pack in one direction, always in source order.
final class PassState {
  const PassState({
    required this.packId,
    required this.direction,
    required this.wordIds,
    required this.index,
    required this.revealed,
    required this.currentRevealed,
    required this.passNumber,
    required this.startedAt,
  });

  final String packId;
  final Direction direction;

  /// Pack words in source order.
  final List<String> wordIds;

  /// Current card, 0-based.
  final int index;

  /// Unique word ids peeked this pass, in the order they were peeked.
  final List<String> revealed;
  final bool currentRevealed;
  final int passNumber;
  final DateTime startedAt;

  String get currentWordId => wordIds[index];
  bool get isLastCard => index == wordIds.length - 1;
  int get peeks => revealed.length;

  PassState _copy({
    required bool currentRevealed,
    int? index,
    List<String>? revealed,
  }) {
    return PassState(
      packId: packId,
      direction: direction,
      wordIds: wordIds,
      index: index ?? this.index,
      revealed: revealed ?? this.revealed,
      currentRevealed: currentRevealed,
      passNumber: passNumber,
      startedAt: startedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PassState &&
      other.packId == packId &&
      other.direction == direction &&
      _listEquals(other.wordIds, wordIds) &&
      other.index == index &&
      _listEquals(other.revealed, revealed) &&
      other.currentRevealed == currentRevealed &&
      other.passNumber == passNumber &&
      other.startedAt == startedAt;

  @override
  int get hashCode => Object.hash(
    packId,
    direction,
    Object.hashAll(wordIds),
    index,
    Object.hashAll(revealed),
    currentRevealed,
    passNumber,
    startedAt,
  );
}

/// Result of a reducer: the new state (null once the pass is over) and the
/// events for the service to apply.
typedef PassStep = (PassState?, List<LearningEvent>);

/// Starts a pass on the pack's words. Replaces any open pass for this pack and
/// direction (the service deletes it).
PassState startPass({
  required String packId,
  required Direction direction,
  required List<String> wordIds,
  required int passNumber,
  required DateTime now,
}) {
  if (wordIds.isEmpty) throw ArgumentError.value(wordIds, 'wordIds', 'empty');
  return PassState(
    packId: packId,
    direction: direction,
    wordIds: List.unmodifiable(wordIds),
    index: 0,
    revealed: const [],
    currentRevealed: false,
    passNumber: passNumber,
    startedAt: now,
  );
}

/// Show: reveal the current card. A card is revealed at most once per pass.
PassStep show(PassState s) {
  if (s.currentRevealed) return (s, const []);
  final id = s.currentWordId;
  return (
    s._copy(
      revealed: List.unmodifiable([...s.revealed, id]),
      currentRevealed: true,
    ),
    [Revealed(id)],
  );
}

/// Next: move on; on the last card, complete the pass.
PassStep next(PassState s) {
  if (s.isLastCard) return complete(s);
  final i = s.index + 1;
  return (
    s._copy(index: i, currentRevealed: s.revealed.contains(s.wordIds[i])),
    const [],
  );
}

/// Previous: look back at an earlier card. Never adds or removes a reveal.
PassStep previous(PassState s) {
  if (s.index == 0) return (s, const []);
  final i = s.index - 1;
  return (
    s._copy(index: i, currentRevealed: s.revealed.contains(s.wordIds[i])),
    const [],
  );
}

/// Ends the pass; clean when nothing was revealed.
PassStep complete(PassState s) => (
  null,
  [PassCompleted(clean: s.revealed.isEmpty, revealedWordIds: s.revealed)],
);

/// Drops the pass. Reveals already recorded stay recorded.
PassStep abandon(PassState s) => (null, const []);

// ---------------------------------------------------------------------------
// Continue (§7)
// ---------------------------------------------------------------------------

/// What the wordlist's Continue button needs to know about a pack.
final class PackSummary {
  const PackSummary({
    required this.id,
    required this.number,
    required this.progress,
  });

  final String id;
  final int number;
  final PackProgress progress;
}

/// An unfinished pass in the wordlist.
final class OpenPassSummary {
  const OpenPassSummary({
    required this.packId,
    required this.direction,
    required this.updatedAt,
  });

  final String packId;
  final Direction direction;
  final DateTime updatedAt;
}

sealed class ContinueTarget {
  const ContinueTarget();
}

/// Open this pack in this direction ([resume] = an unfinished pass).
final class ContinuePack extends ContinueTarget {
  const ContinuePack(this.packId, this.direction, {this.resume = false});

  final String packId;
  final Direction direction;
  final bool resume;

  @override
  bool operator ==(Object other) =>
      other is ContinuePack &&
      other.packId == packId &&
      other.direction == direction &&
      other.resume == resume;

  @override
  int get hashCode => Object.hash(packId, direction, resume);

  @override
  String toString() => 'ContinuePack($packId, ${direction.name}, $resume)';
}

/// Every pack is Learned; offer a review of [firstPackId].
final class AllLearned extends ContinueTarget {
  const AllLearned(this.firstPackId);

  final String firstPackId;

  @override
  bool operator ==(Object other) =>
      other is AllLearned && other.firstPackId == firstPackId;

  @override
  int get hashCode => firstPackId.hashCode;

  @override
  String toString() => 'AllLearned($firstPackId)';
}

/// Most recently updated open pass › lowest Learning pack › lowest New pack ›
/// all learned. [packs] must not be empty.
ContinueTarget continueTarget({
  required List<PackSummary> packs,
  required List<OpenPassSummary> openPasses,
  required LearnedRule rule,
  required Direction defaultDirection,
}) {
  if (openPasses.isNotEmpty) {
    final latest = openPasses.reduce(
      (a, b) => b.updatedAt.isAfter(a.updatedAt) ? b : a,
    );
    return ContinuePack(latest.packId, latest.direction, resume: true);
  }

  final byNumber = [...packs]..sort((a, b) => a.number.compareTo(b.number));
  for (final wanted in [PackStatus.learning, PackStatus.newPack]) {
    for (final p in byNumber) {
      if (p.progress.status(rule, hasOpenPass: false) == wanted) {
        return ContinuePack(
          p.id,
          neededDirection(p.progress, rule) ?? defaultDirection,
        );
      }
    }
  }
  return AllLearned(byNumber.first.id);
}

/// The first direction (WD before DW) that [rule] still needs mastered, or
/// null when the rule is already met.
Direction? neededDirection(PackProgress progress, LearnedRule rule) {
  if (isLearned(progress.wd, progress.dw, rule)) return null;
  final wdMissing = progress.wd != Mastery.mastered;
  return switch (rule) {
    LearnedRule.both ||
    LearnedRule.either => wdMissing ? Direction.wd : Direction.dw,
    LearnedRule.wdOnly => Direction.wd,
    LearnedRule.dwOnly => Direction.dw,
  };
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
