/// Tone and trait tags (`docs/REQUIREMENTS.md` TAG-1, TAG-2).
library;

import 'models.dart';

/// A word's tags: at most one tone, any combination of traits.
final class WordTags {
  const WordTags({
    this.tone,
    this.counterIntuitive = false,
    this.multipleMeanings = false,
  });

  final Tone? tone;
  final bool counterIntuitive;
  final bool multipleMeanings;

  bool has(Trait t) => switch (t) {
    Trait.counterIntuitive => counterIntuitive,
    Trait.multipleMeanings => multipleMeanings,
  };

  bool get isEmpty => tone == null && !counterIntuitive && !multipleMeanings;

  /// Tapping a tone button: selects it, or clears it if it is already active.
  WordTags tapTone(Tone t) => WordTags(
    tone: tone == t ? null : t,
    counterIntuitive: counterIntuitive,
    multipleMeanings: multipleMeanings,
  );

  /// Tapping a trait button: toggles it; the tone is untouched.
  WordTags toggle(Trait t) => WordTags(
    tone: tone,
    counterIntuitive: t == Trait.counterIntuitive
        ? !counterIntuitive
        : counterIntuitive,
    multipleMeanings: t == Trait.multipleMeanings
        ? !multipleMeanings
        : multipleMeanings,
  );

  @override
  bool operator ==(Object other) =>
      other is WordTags &&
      other.tone == tone &&
      other.counterIntuitive == counterIntuitive &&
      other.multipleMeanings == multipleMeanings;

  @override
  int get hashCode => Object.hash(tone, counterIntuitive, multipleMeanings);

  @override
  String toString() =>
      'WordTags(${tone?.name}, ci: $counterIntuitive, mm: $multipleMeanings)';
}

/// Tag node keys used in tree ids (`tag:<wlId>:<key>`, `docs/UI_UX.md` §8).
const untaggedKey = 'untagged';

String toneKey(Tone t) => t.name;
String traitKey(Trait t) => t.name;
