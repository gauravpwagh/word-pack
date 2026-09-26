import 'package:flutter/material.dart';

import '../../data/db/database.dart';
import '../../domain/pos.dart';
import '../card/dashed_border_painter.dart';
import '../card/tag_badges.dart';
import '../card/tag_style.dart';
import '../theme/wp_colors.dart';
import '../theme/wp_text.dart';
import '../theme/wp_tokens.dart';

/// List mode of the explorer: term · pos with the badges on the first line,
/// the whole definition below it (never cut, D-33), and the tag visuals of a
/// list row (4 px tone edge, small badges, dashed outline inset 4 px). Rows
/// grow with the definition. Tapping a row opens it in card mode.
class WordListView extends StatelessWidget {
  const WordListView({super.key, required this.words, required this.onOpen});

  final List<Word> words;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(WpSpace.lg),
      itemCount: words.length,
      separatorBuilder: (_, _) => const SizedBox(height: WpSpace.sm),
      itemBuilder: (context, i) =>
          _WordRow(word: words[i], onTap: () => onOpen(i)),
    );
  }
}

class _WordRow extends StatelessWidget {
  const _WordRow({required this.word, required this.onTap});

  final Word word;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wp = WpColors.of(context);
    final text = WpText.of(context);
    final tone = word.tone;
    final pos = posLabel(word.pos, word.posRaw);
    final radius = BorderRadius.circular(WpRadius.packTile);

    // One screen-reader item per row: term, POS, definition, tags.
    return MergeSemantics(
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomPaint(
          foregroundPainter: word.counterIntuitive
              ? DashedBorderPainter(
                  color: wp.counterOutline,
                  radius: WpRadius.packTile - 4,
                  inset: 4,
                )
              : null,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: WpSize.minTarget,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      WpSpace.lg,
                      WpSpace.md,
                      WpSpace.md,
                      WpSpace.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: word.term,
                                      style: text.cardAnswer.copyWith(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (pos != null)
                                      TextSpan(
                                        text: '  $pos',
                                        style: text.posChip.copyWith(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                        semanticsLabel:
                                            ' ${posFullName(word.pos, word.posRaw)}',
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (TagBadges.hasAny(word)) ...[
                              const SizedBox(width: WpSpace.sm),
                              TagBadges(word: word, small: true),
                            ],
                          ],
                        ),
                        const SizedBox(height: WpSpace.xs),
                        Text(
                          word.definition,
                          key: ValueKey('definition-${word.id}'),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                if (tone != null)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: WpSize.toneEdgeRow,
                    child: ColoredBox(color: TagStyle.toneColor(wp, tone)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
