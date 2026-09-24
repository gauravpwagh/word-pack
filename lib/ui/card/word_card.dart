import 'package:flutter/material.dart';

import '../../data/db/database.dart';
import '../../domain/models.dart';
import '../../l10n/app_localizations.dart';
import '../theme/wp_colors.dart';
import '../theme/wp_text.dart';
import '../theme/wp_tokens.dart';
import 'dashed_border_painter.dart';
import 'pos_chip.dart';
import 'tag_badges.dart';
import 'tag_style.dart';

enum WordCardVariant { learn, review, browse }

/// The study card, one widget for learning, review and the explorer
/// (`docs/UI_UX.md` §3). Shows the prompt side; the answer's space is always
/// reserved so revealing it never moves anything else.
class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.word,
    required this.direction,
    required this.revealed,
    this.variant = WordCardVariant.learn,
    this.showPos = true,
    this.categoryPath,
    this.onTap,
  });

  final Word word;
  final Direction direction;
  final bool revealed;
  final WordCardVariant variant;
  final bool showPos;

  /// "Emotions › Anger", shown under the prompt when the word has one.
  final String? categoryPath;

  /// Tapping the card: Show (learn/review) or reveal (explorer).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= WpBreakpoints.expanded;

    final wordSide = _WordSide(word: word, showPos: showPos, wide: wide);
    final definitionSide = _DefinitionSide(
      definition: word.definition,
      asPrompt: direction == Direction.dw,
    );
    final prompt = direction == Direction.wd ? wordSide : definitionSide;
    final answer = direction == Direction.wd ? definitionSide : wordSide;

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final wp = WpColors.of(context);
    final tone = word.tone;
    final tint = tone == null ? null : TagStyle.toneTint(wp, tone);
    final dashed = word.counterIntuitive;
    final tagLabels = TagBadges.labels(AppLocalizations.of(context), word);
    const tween = Duration(milliseconds: 100);

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(
        WpSpace.xl,
        WpSpace.md,
        WpSpace.md,
        WpSpace.xl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge row is always reserved so tagging never moves the card.
          SizedBox(
            height: WpSize.badge,
            child: Align(
              alignment: Alignment.centerRight,
              // Announced after the word instead (see below).
              child: ExcludeSemantics(child: TagBadges(word: word)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: WpSpace.md),
            child: Column(
              children: [
                prompt,
                if (categoryPath != null) ...[
                  const SizedBox(height: WpSpace.sm),
                  Text(
                    categoryPath!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: WpSpace.lg),
                Divider(color: theme.colorScheme.outlineVariant),
                const SizedBox(height: WpSpace.lg),
                // Always laid out; only its opacity changes.
                AnimatedOpacity(
                  key: const ValueKey('answer'),
                  opacity: revealed ? 1 : 0,
                  duration: reduceMotion || !revealed
                      ? Duration.zero
                      : const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  child: ExcludeSemantics(excluding: !revealed, child: answer),
                ),
                // Screen readers hear the tags after the word: "absurd,
                // adjective, Negative, Counter-intuitive".
                if (tagLabels.isNotEmpty)
                  Semantics(
                    label: tagLabels.join(', '),
                    child: const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    return Semantics(
      container: true,
      child: AnimatedContainer(
        key: const ValueKey('card-surface'),
        duration: reduceMotion ? Duration.zero : tween,
        decoration: BoxDecoration(
          color: tint ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(WpRadius.card),
          // The dashed outline replaces the 1 px border, which stays as a
          // transparent spacer so nothing moves.
          border: Border.all(
            color: dashed
                ? Colors.transparent
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: CustomPaint(
          foregroundPainter: dashed
              ? DashedBorderPainter(
                  color: wp.counterOutline,
                  radius: WpRadius.card,
                )
              : null,
          child: Material(
            type: MaterialType.transparency,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(WpRadius.card),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              excludeFromSemantics: true,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: WpSize.cardMinHeight,
                  minWidth: double.infinity,
                ),
                child: Stack(
                  children: [
                    body,
                    // Tone edge, painted inside so it never shifts content.
                    if (tone != null)
                      Positioned(
                        key: const ValueKey('tone-edge'),
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: WpSize.toneEdgeCard,
                        child: ColoredBox(color: TagStyle.toneColor(wp, tone)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WordSide extends StatelessWidget {
  const _WordSide({
    required this.word,
    required this.showPos,
    required this.wide,
  });

  final Word word;
  final bool showPos;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final text = WpText.of(context);
    return Column(
      children: [
        Text(
          word.term,
          textAlign: TextAlign.center,
          style: (wide ? text.cardWordWide : text.cardWord).copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (showPos && word.pos != null) ...[
          const SizedBox(height: WpSpace.sm),
          PosChip(pos: word.pos, posRaw: word.posRaw),
        ],
      ],
    );
  }
}

class _DefinitionSide extends StatelessWidget {
  const _DefinitionSide({required this.definition, required this.asPrompt});

  final String definition;
  final bool asPrompt;

  @override
  Widget build(BuildContext context) {
    final text = WpText.of(context);
    final style = !asPrompt
        ? text.cardAnswer
        : definition.length > WpText.longPromptChars
        ? text.cardPromptLong
        : text.cardPrompt;
    return Text(
      definition,
      textAlign: asPrompt && definition.length > WpText.longPromptChars
          ? TextAlign.start
          : TextAlign.center,
      style: style.copyWith(color: Theme.of(context).colorScheme.onSurface),
    );
  }
}
