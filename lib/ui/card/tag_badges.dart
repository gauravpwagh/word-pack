import 'package:flutter/material.dart';

import '../../data/db/database.dart';
import '../../domain/models.dart';
import '../../l10n/app_localizations.dart';
import '../theme/wp_colors.dart';
import '../theme/wp_tokens.dart';
import 'tag_style.dart';

/// Icon badges for a word's tags, in the order tone · counter-intuitive ·
/// multiple meanings. Each has a tooltip and a spoken label.
class TagBadges extends StatelessWidget {
  const TagBadges({super.key, required this.word, this.small = false});

  final Word word;

  /// List-row size (28) instead of card size (32).
  final bool small;

  static bool hasAny(Word w) =>
      w.tone != null || w.counterIntuitive || w.multipleMeanings;

  /// Spoken names of the word's tags, in badge order.
  static List<String> labels(AppLocalizations l10n, Word w) => [
    if (w.tone case final tone?) TagStyle.toneLabel(l10n, tone),
    if (w.counterIntuitive) TagStyle.traitLabel(l10n, Trait.counterIntuitive),
    if (w.multipleMeanings) TagStyle.traitLabel(l10n, Trait.multipleMeanings),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wp = WpColors.of(context);
    final surface = Theme.of(context).colorScheme.surface;
    final tone = word.tone;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tone != null)
          _Badge(
            icon: TagStyle.toneIcon(tone),
            label: TagStyle.toneLabel(l10n, tone),
            color: TagStyle.toneColor(wp, tone),
            background: surface,
            ring: true,
            small: small,
          ),
        for (final t in Trait.values)
          if (t == Trait.counterIntuitive
              ? word.counterIntuitive
              : word.multipleMeanings)
            _Badge(
              icon: TagStyle.traitIcon(t),
              label: TagStyle.traitLabel(l10n, t),
              color: TagStyle.traitColor(wp, t),
              background: TagStyle.traitBackground(wp, t),
              small: small,
            ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.small,
    this.ring = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final bool small;

  /// Tone badges are a ring in the tone colour on the surface.
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final size = small ? WpSize.badgeRow : WpSize.badge;
    return Padding(
      padding: const EdgeInsets.only(left: WpSpace.xs),
      child: Semantics(
        label: label,
        excludeSemantics: true,
        child: Tooltip(
          message: label,
          excludeFromSemantics: true,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(WpRadius.badge),
              border: ring ? Border.all(color: color, width: 1.5) : null,
            ),
            child: Icon(
              icon,
              size: small ? 18 : WpSize.badgeIcon,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
