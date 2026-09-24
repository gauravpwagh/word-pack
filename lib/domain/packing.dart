/// Pack generation and the pack-size rebuild (`docs/LEARNING_LOGIC.md` §6).
library;

import 'learning.dart';
import 'models.dart';

/// Allowed pack sizes (setting).
const int minPackSize = 5;
const int maxPackSize = 100;
const int defaultPackSize = 30;

/// Splits [items] into consecutive groups of [size]; the last may be shorter.
List<List<T>> chunk<T>(List<T> items, int size) {
  if (size < 1) throw ArgumentError.value(size, 'size', 'must be ≥ 1');
  return [
    for (var i = 0; i < items.length; i += size)
      items.sublist(i, i + size > items.length ? items.length : i + size),
  ];
}

/// The per-word learning record a rebuild carries over.
final class WordProgress {
  const WordProgress({
    required this.wordId,
    this.masteredWd = false,
    this.masteredDw = false,
    this.revealCountWd = 0,
    this.revealCountDw = 0,
  });

  final String wordId;
  final bool masteredWd;
  final bool masteredDw;
  final int revealCountWd;
  final int revealCountDw;

  bool mastered(Direction d) => d == Direction.wd ? masteredWd : masteredDw;
  int revealCount(Direction d) =>
      d == Direction.wd ? revealCountWd : revealCountDw;
}

/// A pack's mastery in [d], derived from its words.
Mastery deriveMastery(List<WordProgress> words, Direction d) {
  if (words.every((w) => w.mastered(d))) return Mastery.mastered;
  if (words.any((w) => w.mastered(d) || w.revealCount(d) > 0)) {
    return Mastery.learning;
  }
  return Mastery.unseen;
}

/// One pack to create.
final class PackPlan {
  const PackPlan({
    required this.number,
    required this.wordIds,
    required this.progress,
    required this.learnedAt,
  });

  /// 1-based.
  final int number;

  /// Consecutive words, in position order.
  final List<String> wordIds;
  final PackProgress progress;

  /// Set when the new pack already counts as Learned.
  final DateTime? learnedAt;
}

/// New packs at import: all unseen.
List<PackPlan> packsForImport(List<String> wordIdsInOrder, int size) => [
  for (final (i, ids) in chunk(wordIdsInOrder, size).indexed)
    PackPlan(
      number: i + 1,
      wordIds: ids,
      progress: const PackProgress(),
      learnedAt: null,
    ),
];

/// Packs of one wordlist after a pack-size change. [words] must be in
/// position order. Mastery comes from the words, so a new pack is Learned only
/// if every word in it had been learned before.
List<PackPlan> rebuildPacks({
  required List<WordProgress> words,
  required int size,
  required LearnedRule rule,
  required DateTime now,
}) {
  return [
    for (final (i, group) in chunk(words, size).indexed)
      _plan(i + 1, group, rule, now),
  ];
}

PackPlan _plan(
  int number,
  List<WordProgress> group,
  LearnedRule rule,
  DateTime now,
) {
  final progress = PackProgress(
    wd: deriveMastery(group, Direction.wd),
    dw: deriveMastery(group, Direction.dw),
  );
  final learned =
      progress.status(rule, hasOpenPass: false) == PackStatus.learned;
  return PackPlan(
    number: number,
    wordIds: [for (final w in group) w.wordId],
    progress: progress,
    learnedAt: learned ? now : null,
  );
}
