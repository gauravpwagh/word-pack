/// Core enums shared by every layer (`docs/LEARNING_LOGIC.md` §2).
library;

/// `wd` = show the word, recall the definition; `dw` = the reverse.
enum Direction {
  wd,
  dw;

  Direction get other => this == wd ? dw : wd;
}

/// Per pack and direction.
enum Mastery { unseen, learning, mastered }

/// Derived, never stored (`packStatus` in `learning.dart`).
enum PackStatus { newPack, learning, learned }

/// Which clean passes make a pack Learned (setting, default [both]).
enum LearnedRule { both, either, wdOnly, dwOnly }

/// Single-choice tone tag.
enum Tone { positive, negative, neutral }

/// Independent trait flags.
enum Trait { counterIntuitive, multipleMeanings }
