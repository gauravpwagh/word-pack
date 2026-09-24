import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/domain/learning.dart';
import 'package:wordpack/domain/models.dart';

final t0 = DateTime.utc(2026, 9, 24, 10);
const words = ['abbey', 'abide', 'abound', 'absence', 'absorb'];

PassState start([Direction d = Direction.wd]) => startPass(
  packId: 'p1',
  direction: d,
  wordIds: words,
  passNumber: 1,
  now: t0,
);

/// Runs a whole pass, pressing Show on the cards in [peekAt] (0-based).
List<LearningEvent> runPass(PassState s, {Set<int> peekAt = const {}}) {
  final events = <LearningEvent>[];
  PassState? state = s;
  while (state != null) {
    if (peekAt.contains(state.index)) {
      final (after, e) = show(state);
      events.addAll(e);
      state = after;
    }
    final (after, e) = next(state!);
    events.addAll(e);
    state = after;
  }
  return events;
}

PackProgress applyAll(
  PackProgress p,
  Direction d,
  List<LearningEvent> events, {
  bool demote = false,
}) {
  for (final e in events) {
    p = applyEvent(p, d, e, demoteOnReveal: demote);
  }
  return p;
}

void main() {
  group('pass state machine', () {
    test('U-14 a pass with only Next is clean and masters the direction', () {
      final events = runPass(start());
      expect(events, [const PassCompleted(clean: true, revealedWordIds: [])]);
      expect(
        applyAll(const PackProgress(), Direction.wd, events).wd,
        Mastery.mastered,
      );
    });

    test('U-15 one Show emits Revealed and fails the pass', () {
      final events = runPass(start(), peekAt: {3});
      expect(events, [
        const Revealed('absence'),
        const PassCompleted(clean: false, revealedWordIds: ['absence']),
      ]);
      final p = applyAll(const PackProgress(), Direction.wd, events);
      expect(p.wd, Mastery.learning);
    });

    test('U-16 Show twice on the same card counts one reveal', () {
      final (s1, e1) = show(start());
      final (s2, e2) = show(s1!);
      expect(e1, [const Revealed('abbey')]);
      expect(e2, isEmpty);
      expect(s2, s1);
      expect(s2!.peeks, 1);
    });

    test('U-17 Previous restores the reveal state and never adds one', () {
      var (s, _) = show(start()); // card 0 revealed
      (s, _) = next(s!); // card 1, not revealed
      expect(s!.currentRevealed, isFalse);
      final (back, events) = previous(s);
      expect(back!.index, 0);
      expect(back.currentRevealed, isTrue);
      expect(events, isEmpty);
      expect(back.revealed, ['abbey']);

      final (fwd, _) = next(back);
      expect(fwd!.currentRevealed, isFalse);
      final (stay, none) = previous(start());
      expect(stay, start());
      expect(none, isEmpty);
    });

    test('U-18 cards are always the pack words in source order', () {
      PassState? s = start(Direction.dw);
      final seen = <String>[];
      while (s != null) {
        seen.add(s.currentWordId);
        (s, _) = next(s);
      }
      expect(seen, words);
    });

    test('startPass rejects an empty pack; abandon drops the pass', () {
      expect(
        () => startPass(
          packId: 'p',
          direction: Direction.wd,
          wordIds: const [],
          passNumber: 1,
          now: t0,
        ),
        throwsArgumentError,
      );
      final (s, e) = abandon(start());
      expect(s, isNull);
      expect(e, isEmpty);
    });

    test('complete mid-pass reports the reveals so far', () {
      final (s, _) = show(start());
      expect(complete(s!).$2, [
        const PassCompleted(clean: false, revealedWordIds: ['abbey']),
      ]);
    });

    test('state equality and hashing', () {
      expect(start(), start());
      expect(start().hashCode, start().hashCode);
      expect(start() == start(Direction.dw), isFalse);
      expect(start().isLastCard, isFalse);
      expect(
        const PassCompleted(clean: true, revealedWordIds: []).hashCode,
        const PassCompleted(clean: true, revealedWordIds: []).hashCode,
      );
      expect(const Revealed('a').hashCode, const Revealed('a').hashCode);
      expect(
        const PassCompleted(clean: false, revealedWordIds: ['a']) ==
            const PassCompleted(clean: false, revealedWordIds: ['b']),
        isFalse,
      );
      expect(
        const PassCompleted(clean: false, revealedWordIds: ['a']) ==
            const PassCompleted(clean: false, revealedWordIds: ['a', 'b']),
        isFalse,
      );
      expect(const Revealed('a').toString(), 'Revealed(a)');
      expect(
        const PassCompleted(clean: true, revealedWordIds: []).toString(),
        'PassCompleted(clean: true, [])',
      );
    });
  });

  group('pack status', () {
    test('U-19 the worked example (rule = both)', () {
      const rule = LearnedRule.both;
      var p = const PackProgress();
      PackStatus status({bool open = false}) =>
          p.status(rule, hasOpenPass: open);

      expect(status(), PackStatus.newPack); // import

      // Start WD pass, Next ×3.
      var (s, _) = next(start());
      (s, _) = next(s!);
      (s, _) = next(s!);
      expect(p, const PackProgress());
      expect(status(open: true), PackStatus.learning);

      // Show on card 4.
      final (shown, revealEvents) = show(s!);
      p = applyAll(p, Direction.wd, revealEvents);
      expect(p, const PackProgress(wd: Mastery.learning));
      expect(status(open: true), PackStatus.learning);

      // Finish the pass (1 peek).
      var (rest, doneEvents) = next(shown!);
      (rest, doneEvents) = next(rest!);
      expect(rest, isNull);
      p = applyAll(p, Direction.wd, doneEvents);
      expect(p, const PackProgress(wd: Mastery.learning));
      expect(status(), PackStatus.learning);

      // Repeat WD, 0 peeks.
      p = applyAll(p, Direction.wd, runPass(start()));
      expect(p, const PackProgress(wd: Mastery.mastered));
      expect(status(), PackStatus.learning);

      // DW pass, 2 peeks.
      p = applyAll(
        p,
        Direction.dw,
        runPass(start(Direction.dw), peekAt: {0, 2}),
      );
      expect(p, const PackProgress(wd: Mastery.mastered, dw: Mastery.learning));
      expect(status(), PackStatus.learning);

      // DW pass, 0 peeks.
      p = applyAll(p, Direction.dw, runPass(start(Direction.dw)));
      expect(p, const PackProgress(wd: Mastery.mastered, dw: Mastery.mastered));
      expect(status(), PackStatus.learned);
    });

    test('U-20 learned rules', () {
      const wdOnly = PackProgress(wd: Mastery.mastered);
      const dwOnly = PackProgress(dw: Mastery.mastered);
      PackStatus s(PackProgress p, LearnedRule r) =>
          p.status(r, hasOpenPass: false);

      expect(s(wdOnly, LearnedRule.either), PackStatus.learned);
      expect(s(dwOnly, LearnedRule.either), PackStatus.learned);
      expect(s(wdOnly, LearnedRule.wdOnly), PackStatus.learned);
      expect(s(dwOnly, LearnedRule.wdOnly), PackStatus.learning);
      expect(s(dwOnly, LearnedRule.dwOnly), PackStatus.learned);
      expect(s(wdOnly, LearnedRule.dwOnly), PackStatus.learning);
      expect(s(wdOnly, LearnedRule.both), PackStatus.learning);
      expect(s(const PackProgress(), LearnedRule.either), PackStatus.newPack);
    });

    test('U-21 review peeks: demote off keeps Learned, on demotes', () {
      const learned = PackProgress(wd: Mastery.mastered, dw: Mastery.mastered);
      final events = runPass(start(), peekAt: {1});

      final kept = applyAll(learned, Direction.wd, events);
      expect(kept, learned);
      expect(
        kept.status(LearnedRule.both, hasOpenPass: false),
        PackStatus.learned,
      );
      expect(revealDemotes(Mastery.mastered, demoteOnReveal: false), isFalse);

      final demoted = applyAll(learned, Direction.wd, events, demote: true);
      expect(demoted.wd, Mastery.learning);
      expect(
        demoted.status(LearnedRule.both, hasOpenPass: false),
        PackStatus.learning,
      );
      expect(revealDemotes(Mastery.mastered, demoteOnReveal: true), isTrue);
      expect(revealDemotes(Mastery.learning, demoteOnReveal: true), isFalse);
    });

    test('PackProgress value semantics', () {
      const a = PackProgress(wd: Mastery.learning);
      expect(a, const PackProgress(wd: Mastery.learning));
      expect(a.hashCode, const PackProgress(wd: Mastery.learning).hashCode);
      expect(a.of(Direction.dw), Mastery.unseen);
      expect(a.toString(), 'PackProgress(wd: learning, dw: unseen)');
      expect(Direction.wd.other, Direction.dw);
      expect(Direction.dw.other, Direction.wd);
    });
  });

  group('U-22 continueTarget', () {
    PackSummary pack(int n, PackProgress p) =>
        PackSummary(id: 'p$n', number: n, progress: p);
    const learned = PackProgress(wd: Mastery.mastered, dw: Mastery.mastered);
    const wdDone = PackProgress(wd: Mastery.mastered);
    const fresh = PackProgress();

    ContinueTarget target(
      List<PackSummary> packs, {
      List<OpenPassSummary> open = const [],
      LearnedRule rule = LearnedRule.both,
      Direction dflt = Direction.wd,
    }) => continueTarget(
      packs: packs,
      openPasses: open,
      rule: rule,
      defaultDirection: dflt,
    );

    test('an open pass wins; the most recently updated one', () {
      final t = target(
        [pack(1, fresh), pack(2, wdDone)],
        open: [
          OpenPassSummary(packId: 'p1', direction: Direction.wd, updatedAt: t0),
          OpenPassSummary(
            packId: 'p2',
            direction: Direction.dw,
            updatedAt: t0.add(const Duration(minutes: 1)),
          ),
          OpenPassSummary(packId: 'p1', direction: Direction.dw, updatedAt: t0),
        ],
      );
      expect(t, const ContinuePack('p2', Direction.dw, resume: true));
    });

    test('then the lowest Learning pack, in the direction still needed', () {
      final t = target([pack(1, learned), pack(3, wdDone), pack(2, wdDone)]);
      expect(t, const ContinuePack('p2', Direction.dw));
    });

    test('then the lowest New pack', () {
      expect(
        target([pack(1, learned), pack(2, fresh), pack(3, fresh)]),
        const ContinuePack('p2', Direction.wd),
      );
    });

    test('direction follows the learned rule', () {
      expect(
        target([pack(1, fresh)], rule: LearnedRule.dwOnly),
        const ContinuePack('p1', Direction.dw),
      );
      expect(
        target([pack(1, fresh)], rule: LearnedRule.wdOnly),
        const ContinuePack('p1', Direction.wd),
      );
      expect(neededDirection(learned, LearnedRule.both), isNull);
      expect(neededDirection(fresh, LearnedRule.either), Direction.wd);
    });

    test('all learned → review pack 1', () {
      final t = target([pack(2, learned), pack(1, learned)]);
      expect(t, const AllLearned('p1'));
      expect(t.hashCode, const AllLearned('p1').hashCode);
      expect(t.toString(), 'AllLearned(p1)');
      expect(
        const ContinuePack('p', Direction.wd).hashCode,
        const ContinuePack('p', Direction.wd).hashCode,
      );
      expect(
        const ContinuePack('p', Direction.wd).toString(),
        'ContinuePack(p, wd, false)',
      );
    });
  });
}
