import 'package:flutter/material.dart';

import '../../data/db/database.dart';
import '../../domain/models.dart';
import '../../domain/tags.dart';
import '../../l10n/app_localizations.dart';
import '../card/tag_style.dart';
import '../theme/wp_colors.dart';
import '../theme/wp_tokens.dart';

/// The five one-tap tag buttons (`docs/UI_UX.md` §5). Tones are single-choice
/// (tapping the active one clears it); traits toggle independently. Shown only
/// for words of a Learned pack.
class QuickTagBar extends StatelessWidget {
  const QuickTagBar({
    super.key,
    required this.word,
    required this.onTone,
    required this.onTrait,
  });

  final Word word;

  /// The new tone, or null to clear it.
  final ValueChanged<Tone?> onTone;
  final ValueChanged<Trait> onTrait;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wp = WpColors.of(context);
    final tags = WordTags(
      tone: word.tone,
      counterIntuitive: word.counterIntuitive,
      multipleMeanings: word.multipleMeanings,
    );

    Widget button({
      required Key key,
      required IconData icon,
      required String label,
      required bool selected,
      required Color color,
      required Color background,
      required VoidCallback onTap,
    }) {
      return FilterChip(
        key: key,
        selected: selected,
        showCheckmark: false,
        avatar: Icon(icon, color: color, fill: selected ? 1 : 0),
        label: Text(label),
        selectedColor: background,
        side: BorderSide(
          color: selected ? color : Theme.of(context).colorScheme.outline,
          width: selected ? 1.5 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WpRadius.field),
        ),
        materialTapTargetSize: MaterialTapTargetSize.padded,
        onSelected: (_) => onTap(),
      );
    }

    // Tone row and trait row; each wraps at large text sizes.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: WpSpace.sm,
          children: [
            for (final t in Tone.values)
              button(
                key: ValueKey('tone-${t.name}'),
                icon: TagStyle.toneIcon(t),
                label: TagStyle.toneLabel(l10n, t),
                selected: tags.tone == t,
                color: TagStyle.toneColor(wp, t),
                background:
                    TagStyle.toneTint(wp, t) ??
                    Theme.of(context).colorScheme.surfaceContainerHigh,
                onTap: () => onTone(tags.tapTone(t).tone),
              ),
          ],
        ),
        Wrap(
          spacing: WpSpace.sm,
          children: [
            for (final t in Trait.values)
              button(
                key: ValueKey('trait-${t.name}'),
                icon: TagStyle.traitIcon(t),
                label: TagStyle.traitLabel(l10n, t),
                selected: tags.has(t),
                color: TagStyle.traitColor(wp, t),
                background: TagStyle.traitBackground(wp, t),
                onTap: () => onTrait(t),
              ),
          ],
        ),
      ],
    );
  }
}
