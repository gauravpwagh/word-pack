import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/models.dart';
import '../../l10n/app_localizations.dart';
import '../theme/wp_colors.dart';

String directionLabel(AppLocalizations l10n, Direction d) =>
    d == Direction.wd ? l10n.directionWd : l10n.directionDw;

String statusLabel(AppLocalizations l10n, PackStatus s) => switch (s) {
  PackStatus.newPack => l10n.statusNew,
  PackStatus.learning => l10n.statusLearning,
  PackStatus.learned => l10n.statusLearned,
};

/// Icon and colours for a pack status (`docs/UI_UX.md` §8, §9).
({IconData icon, bool filled, Color color, Color? background}) statusStyle(
  BuildContext context,
  PackStatus s,
) {
  final wp = WpColors.of(context);
  return switch (s) {
    PackStatus.newPack => (
      icon: Symbols.radio_button_unchecked_rounded,
      filled: false,
      color: wp.statusNew,
      background: null,
    ),
    PackStatus.learning => (
      icon: Symbols.clock_loader_40_rounded,
      filled: false,
      color: wp.statusLearning,
      background: wp.statusLearningBg,
    ),
    PackStatus.learned => (
      icon: Symbols.check_circle_rounded,
      filled: true,
      color: wp.statusLearned,
      background: wp.statusLearnedBg,
    ),
  };
}
