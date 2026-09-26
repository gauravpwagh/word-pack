# Learning logic

The core of the app. Implement as **pure Dart** in `lib/domain/learning.dart` and `lib/domain/packing.dart`: no Flutter imports, no drift, no `DateTime.now()` inside (pass `now` in). Fully unit-tested.

## 1. Concepts

- **Pack**: up to `packSize` consecutive words of one wordlist, in file order.
- **Direction**: `WD` (prompt = word, answer = definition) or `DW` (prompt = definition, answer = word).
- **Pass**: one run through every card of a pack in one direction, **always in source order**.
- **Reveal / peek**: pressing **Show**. A card can be revealed at most once per pass.
- **Clean pass**: a completed pass with zero reveals.
- **Review**: studying a pack that is already Learned.

Rule from the brief: *if the user looks at any definition, the whole pack is under learning; once the user goes through all words of the pack without looking, it is learned.* The learned rule setting decides which directions need a clean pass (default: both).

## 2. Mastery and status

Per pack and direction:

```dart
enum Mastery { unseen, learning, mastered }
enum Direction { wd, dw }
enum PackStatus { newPack, learning, learned }
enum LearnedRule { both, either, wdOnly, dwOnly }
```

| Event | Effect on `pack.mastery(dir)` | Effect on words |
|---|---|---|
| Show pressed | → `learning` (if already `mastered`: only when `demoteOnReveal` is on) | `revealCount(dir) += 1` for that word; if demoting, `word.mastered(dir) = false` for that word |
| Pass completed, 0 reveals | → `mastered` | `word.mastered(dir) = true` for every word of the pack |
| Pass completed, ≥ 1 reveal | stays / becomes `learning` | — |

Pack status is **derived**, never stored:

```dart
PackStatus packStatus(Mastery wd, Mastery dw, LearnedRule rule, {required bool hasOpenPass}) {
  final w = wd == Mastery.mastered, d = dw == Mastery.mastered;
  final learned = switch (rule) {
    LearnedRule.both => w && d,
    LearnedRule.either => w || d,
    LearnedRule.wdOnly => w,
    LearnedRule.dwOnly => d,
  };
  if (learned) return PackStatus.learned;
  if (wd == Mastery.unseen && dw == Mastery.unseen && !hasOpenPass) return PackStatus.newPack;
  return PackStatus.learning;
}
```

Because it's derived, changing the learned rule in Settings re-evaluates all packs instantly. `pack.learnedAt` is written the first time a pass completion makes the status `learned`.

A **word is Learned** when its pack is Learned. Categorising is allowed only for Learned words (`DECISIONS.md` D-9); tone and traits can be set on any word, while learning too (D-32), and never count as a peek.

Worked example (rule = both):

| Step | WD | DW | Pack status |
|---|---|---|---|
| Import | unseen | unseen | New |
| Start WD pass, Next ×3 | unseen | unseen | Learning (open pass) |
| Show on card 4 | learning | unseen | Learning |
| Finish pass (1 peek) | learning | unseen | Learning |
| Repeat WD pass, 0 peeks | mastered | unseen | Learning |
| DW pass, 2 peeks | mastered | learning | Learning |
| DW pass, 0 peeks | mastered | mastered | **Learned** |

With rule = `either`, the pack would already be Learned after row 5.

## 3. Pass state machine

```dart
@immutable
class PassState {
  final String packId;
  final Direction direction;
  final List<String> wordIds;     // pack words in source order
  final int index;                // current card, 0-based
  final List<String> revealed;    // unique word ids peeked this pass
  final bool currentRevealed;
  final int passNumber;
  final DateTime startedAt;
  // const constructor + copyWith (hand-written or freezed)
}
```

```
 start ─► PROMPT ──Show──► ANSWER
            │  ▲             │
            │  └────Next─────┤   (not last card)
            └──────Next──────┘
                   │ Next on last card
                   ▼
               COMPLETE ─► summary
```

| Action | Precondition | Effect |
|---|---|---|
| `start(pack, direction)` | — | New state; replaces any open pass for this pack + direction. |
| `show()` | current card not revealed | `currentRevealed = true`; add word to `revealed`; emit `Revealed(wordId)` event. |
| `next()` | — | On last card → `complete()`. Else `index + 1`; `currentRevealed = revealed.contains(wordIds[index])`. |
| `previous()` (P1) | `index > 0` | `index - 1`; `currentRevealed = revealed.contains(wordIds[index])`. Never adds a reveal. |
| `complete()` | — | `clean = revealed.isEmpty`; emit `PassCompleted(clean, revealed)`; the pass is deleted. |
| `abandon()` | — | Delete the pass; reveals already recorded stay recorded. |

Reducer functions return a record `(PassState? state, List<LearningEvent> events)`; events are a sealed class (`Revealed`, `PassCompleted`). The `LearningService` applies events to the database in **one transaction** (see the table in §2).

`PassResult` shown on the summary: `packId, direction, clean, peekedWordIds, packStatus, becameLearned`.

**Persistence:** the pass is written to the `pass_sessions` table after every action. On opening a wordlist, if an open pass exists the UI offers "Resume Pack 4 · Word → Definition · card 12 / 30". One open pass per pack per direction.

## 4. Direction switching

- Between passes: just choose the direction for the next `start`.
- Mid-pass: confirm "Switch to Definition → Word? The current pass will restart." → `abandon()` + `start(newDirection)`.
- Default direction comes from Settings; each pack remembers `lastDirection`.

## 5. Review mode

Studying a Learned pack. Same state machine. Differences:
- The card also shows the category controls (for all words, since they are all Learned); the quick tag buttons are there in learning too (D-32).
- Peeks are recorded in word stats and in the summary but, by default, do not change mastery (`demoteOnReveal = false`). If demotion is on and the pack drops to Learning, the category controls disappear until it is Learned again; existing categories and tags are kept and still displayed.

## 6. Pack generation and pack-size change (rebuilds all packs)

**At import:** chunk the wordlist's words by `position` into packs of `packSize`; numbers 1..k; last pack may be shorter; all mastery `unseen`.

**When pack size changes** (confirmation required — "All packs in all wordlists will be rebuilt with 20 words each. Your word progress is kept, but passes in progress will be discarded."):

1. Delete all open passes (all wordlists).
2. For each wordlist: delete all packs, re-chunk all words by `position` with the new size.
3. For each new pack and each direction, derive mastery from its words:

```dart
Mastery deriveMastery(List<WordProgress> words, Direction d) {
  if (words.every((w) => w.mastered(d))) return Mastery.mastered;
  if (words.any((w) => w.mastered(d) || w.revealCount(d) > 0)) return Mastery.learning;
  return Mastery.unseen;
}
```

4. Set `learnedAt` = now for packs whose derived status is `learned`, else null. Pack pass statistics restart at 0.

Consequence: a new pack is Learned only if every word in it had been learned before. Tags and categories are never touched.

Invariants (test them): every word belongs to exactly one pack; pack numbers per wordlist are 1..k; each pack has ≤ packSize words; words in a pack are consecutive by position.

## 7. "Continue"

From a wordlist, **Continue** opens:
1. the most recently updated open pass, else
2. the lowest-numbered pack with status `learning`, else
3. the lowest-numbered pack with status `new`, else
4. "All packs learned 🎉" with a *Review* button for pack 1.

Direction: the open pass's direction; otherwise the first direction the learned rule still needs (WD before DW); otherwise the default direction.

## 8. Statistics recorded

Per word: `revealCountWd`, `revealCountDw`, `masteredWd`, `masteredDw`, `lastSeenAt`, `lastRevealedAt`.
Per pack & direction: `passes`, `cleanPasses`, `lastPassAt`, `masteredAt`.
Only the pass summary uses them in v1; they exist so later features (hardest words, spaced repetition) have data.
