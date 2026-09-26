import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import '../theme/wp_colors.dart';
import '../theme/wp_icons.dart';
import '../theme/wp_tokens.dart';
import 'learn_controller.dart';

enum SummaryAction {
  startOther,
  nextPack,
  review,
  back,
  repeat,
  switchDirection,
}

/// End of a pass (`docs/UI_UX.md` §3): clean pass, pack learned, or finished
/// with peeks. Never offers to categorise (D-9).
class PassSummary extends StatelessWidget {
  const PassSummary({super.key, required this.view, required this.onAction});

  final LearnView view;
  final ValueChanged<SummaryAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final wp = WpColors.of(context);
    final result = view.result!;
    final number = view.pack.number;
    final direction = directionLabel(l10n, result.direction);
    final other = result.direction.other;
    final hasNext = view.nextPack != null;

    final IconData icon;
    final Color color;
    final String title;
    final List<(SummaryAction, String)> actions;
    if (result.becameLearned) {
      icon = WpIcons.checkCircle;
      color = wp.statusLearned;
      title = l10n.summaryLearned(number);
      actions = [
        if (hasNext) (SummaryAction.nextPack, l10n.summaryNextPack),
        (SummaryAction.review, l10n.summaryReview),
        (SummaryAction.back, l10n.summaryBack),
      ];
    } else if (result.clean) {
      final learned = result.status == PackStatus.learned;
      final otherNeeded =
          !learned && view.progress.of(other) != Mastery.mastered;
      icon = WpIcons.taskAlt;
      color = wp.statusLearned;
      title = learned
          ? l10n.summaryCleanReview(number, direction)
          : l10n.summaryClean(number, direction);
      actions = [
        if (otherNeeded)
          (
            SummaryAction.startOther,
            l10n.summaryStart(directionLabel(l10n, other)),
          ),
        if (hasNext) (SummaryAction.nextPack, l10n.summaryNextPack),
        (SummaryAction.back, l10n.summaryBack),
      ];
    } else {
      icon = WpIcons.visibility;
      color = wp.statusLearning;
      final terms = [
        for (final id in result.peekedWordIds) view.wordById(id).term,
      ];
      title = l10n.summaryPeeks(terms.length, terms.join(' · '));
      actions = [
        (SummaryAction.repeat, l10n.summaryRepeat),
        (SummaryAction.switchDirection, l10n.summarySwitch),
        (SummaryAction.back, l10n.summaryBack),
      ];
    }

    final celebrate =
        result.becameLearned && !MediaQuery.disableAnimationsOf(context);
    return Semantics(
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: celebrate ? 0.4 : 1, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Icon(WpIcons.filled(icon), size: 56, color: color),
          ),
          const SizedBox(height: WpSpace.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: result.becameLearned
                ? theme.textTheme.displaySmall
                : theme.textTheme.titleLarge,
          ),
          const SizedBox(height: WpSpace.xl),
          for (final (i, (action, label)) in actions.indexed) ...[
            if (i > 0) const SizedBox(height: WpSpace.sm),
            if (i == 0)
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(WpSize.studyAction),
                ),
                onPressed: () => onAction(action),
                child: Text(label, textAlign: TextAlign.center),
              )
            else
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(WpSize.minTarget),
                ),
                onPressed: () => onAction(action),
                child: Text(label, textAlign: TextAlign.center),
              ),
          ],
        ],
      ),
    );
  }
}
