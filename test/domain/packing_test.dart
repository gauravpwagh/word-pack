import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/domain/learning.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/domain/packing.dart';

final now = DateTime.utc(2026, 9, 24, 10);

List<String> ids(int n) => [for (var i = 0; i < n; i++) 'w$i'];

void expectInvariants(List<PackPlan> packs, int wordCount, int size) {
  final all = [for (final p in packs) ...p.wordIds];
  expect(all, ids(wordCount), reason: 'every word once, consecutive, in order');
  expect(
    [for (final p in packs) p.number],
    [for (var i = 1; i <= packs.length; i++) i],
  );
  for (final p in packs) {
    expect(p.wordIds.length, inInclusiveRange(1, size));
  }
}

void main() {
  test('U-11 998 words at size 30 → 34 packs, last has 8', () {
    final packs = packsForImport(ids(998), defaultPackSize);
    expect(packs, hasLength(34));
    expect(packs.last.wordIds, hasLength(8));
    expect(packs.first.wordIds, ids(30));
    expect(packs.every((p) => p.progress == const PackProgress()), isTrue);
    expect(packs.every((p) => p.learnedAt == null), isTrue);
    expectInvariants(packs, 998, 30);
  });

  test('chunk rejects a size below 1 and handles empty input', () {
    expect(() => chunk([1], 0), throwsArgumentError);
    expect(chunk(<int>[], 5), isEmpty);
    expect(chunk([1, 2, 3, 4, 5], 5), [
      [1, 2, 3, 4, 5],
    ]);
  });

  group('U-12 rebuild to 20', () {
    // Old size 30: old pack 1 (0–29) mastered WD+DW, old pack 2 (30–59)
    // mastered WD only, no other reveals.
    final words = [
      for (var i = 0; i < 998; i++)
        WordProgress(wordId: 'w$i', masteredWd: i < 60, masteredDw: i < 30),
    ];
    final packs = rebuildPacks(
      words: words,
      size: 20,
      rule: LearnedRule.both,
      now: now,
    );

    test('50 packs', () => expect(packs, hasLength(50)));

    test('pack 1 (0–19) is learned', () {
      expect(
        packs[0].progress,
        const PackProgress(wd: Mastery.mastered, dw: Mastery.mastered),
      );
      expect(packs[0].learnedAt, now);
    });

    test('pack 2 (20–39): WD mastered, DW learning', () {
      expect(
        packs[1].progress,
        const PackProgress(wd: Mastery.mastered, dw: Mastery.learning),
      );
      expect(packs[1].learnedAt, isNull);
    });

    test('pack 3 (40–59): WD mastered, DW unseen → status learning', () {
      expect(
        packs[2].progress,
        const PackProgress(wd: Mastery.mastered, dw: Mastery.unseen),
      );
      expect(
        packs[2].progress.status(LearnedRule.both, hasOpenPass: false),
        PackStatus.learning,
      );
    });

    test('pack 4 is new', () {
      expect(
        packs[3].progress.status(LearnedRule.both, hasOpenPass: false),
        PackStatus.newPack,
      );
    });

    test('U-13 rebuild invariants', () => expectInvariants(packs, 998, 20));
  });

  test('deriveMastery counts reveals as learning', () {
    const words = [
      WordProgress(wordId: 'a', revealCountDw: 2),
      WordProgress(wordId: 'b'),
    ];
    expect(deriveMastery(words, Direction.dw), Mastery.learning);
    expect(deriveMastery(words, Direction.wd), Mastery.unseen);
  });
}
