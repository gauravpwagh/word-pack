import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../l10n/app_localizations.dart';
import '../theme/wp_colors.dart';
import '../theme/wp_icons.dart';

/// Icon, label and colours for each tag (`docs/UI_UX.md` §5, §9). Colour is
/// never the only signal: every tag has an icon and a spoken label.
abstract final class TagStyle {
  static IconData toneIcon(Tone t) => switch (t) {
    Tone.positive => WpIcons.sentimentSatisfied,
    Tone.negative => WpIcons.sentimentDissatisfied,
    Tone.neutral => WpIcons.sentimentNeutral,
  };

  static IconData traitIcon(Trait t) => switch (t) {
    Trait.counterIntuitive => WpIcons.psychologyAlt,
    Trait.multipleMeanings => WpIcons.altRoute,
  };

  static String toneLabel(AppLocalizations l10n, Tone t) => switch (t) {
    Tone.positive => l10n.tonePositive,
    Tone.negative => l10n.toneNegative,
    Tone.neutral => l10n.toneNeutral,
  };

  static String traitLabel(AppLocalizations l10n, Trait t) => switch (t) {
    Trait.counterIntuitive => l10n.traitCounterIntuitive,
    Trait.multipleMeanings => l10n.traitMultipleMeanings,
  };

  /// Edge and icon colour of a tone.
  static Color toneColor(WpColors wp, Tone t) => switch (t) {
    Tone.positive => wp.positive,
    Tone.negative => wp.negative,
    Tone.neutral => wp.neutral,
  };

  /// Card background tint; neutral has none.
  static Color? toneTint(WpColors wp, Tone t) => switch (t) {
    Tone.positive => wp.positiveTint,
    Tone.negative => wp.negativeTint,
    Tone.neutral => null,
  };

  static Color traitColor(WpColors wp, Trait t) => switch (t) {
    Trait.counterIntuitive => wp.counter,
    Trait.multipleMeanings => wp.multi,
  };

  static Color traitBackground(WpColors wp, Trait t) => switch (t) {
    Trait.counterIntuitive => wp.counterBg,
    Trait.multipleMeanings => wp.multiBg,
  };
}
