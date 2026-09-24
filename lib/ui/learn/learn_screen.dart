import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/models.dart';
import '../../l10n/app_localizations.dart';
import '../../services/exceptions.dart';
import '../card/word_card.dart';
import '../common/labels.dart';
import '../common/page_scaffold.dart';
import '../common/shortcut_help.dart';
import '../tagging/category_row.dart';
import '../tagging/quick_tag_bar.dart';
import '../theme/wp_colors.dart';
import '../theme/wp_tokens.dart';
import '../wordlist/wordlist_home_screen.dart' show learnPath;
import 'learn_controller.dart';
import 'pass_summary.dart';

/// Learn / Review for one pack (`docs/UI_UX.md` §3).
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key, required this.packId, this.direction});

  final String packId;

  /// `wd` or `dw` from the `dir` query parameter; null = the pack's last
  /// direction.
  final String? direction;

  LearnArgs get _args =>
      (packId: packId, direction: Direction.values.asNameMap()[direction]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(learnControllerProvider(_args));
    return switch (async) {
      AsyncData(:final value) => _Learn(args: _args, view: value),
      // The pack is gone (e.g. packs were rebuilt with a new size).
      AsyncError() => PageScaffold(
        title: l10n.learnTitle,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(WpSpace.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.learnPackMissing, textAlign: TextAlign.center),
                const SizedBox(height: WpSpace.lg),
                FilledButton(
                  onPressed: () => context.go('/'),
                  child: Text(l10n.backToStart),
                ),
              ],
            ),
          ),
        ),
      ),
      _ => PageScaffold(
        title: l10n.learnTitle,
        body: const Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

class _Learn extends ConsumerStatefulWidget {
  const _Learn({required this.args, required this.view});

  final LearnArgs args;
  final LearnView view;

  @override
  ConsumerState<_Learn> createState() => _LearnState();
}

class _LearnState extends ConsumerState<_Learn> {
  final _categoryFocus = FocusNode(debugLabel: 'category');

  LearnArgs get args => widget.args;
  LearnView get view => widget.view;

  @override
  void dispose() {
    _categoryFocus.dispose();
    super.dispose();
  }

  /// Shortcuts are ignored while a text field has focus.
  bool get _typing =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<EditableText>() !=
      null;

  bool get _mobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(learnControllerProvider(args).notifier);
    final pass = view.pass;
    final word = view.current;
    final wide = MediaQuery.sizeOf(context).width >= WpBreakpoints.medium;

    ref.listen(learnControllerProvider(args), (prev, next) {
      final r = next.value?.result;
      if (_mobile && r != null && prev?.value?.result == null) {
        _haptic(
          r.becameLearned
              ? HapticFeedback.mediumImpact
              : HapticFeedback.lightImpact,
        );
      }
    });

    Future<void> onNext() async {
      if (pass == null) return;
      if (_mobile) _haptic(HapticFeedback.lightImpact);
      await controller.next();
    }

    Future<void> onShow() async {
      if (pass == null || pass.currentRevealed) return;
      await controller.show();
    }

    Future<void> onPrevious() async {
      if (pass == null || pass.index == 0) return;
      await controller.previous();
    }

    Future<void> onDirection(Direction to) async {
      if (to == view.direction && pass != null) return;
      final midPass = pass != null && (pass.index > 0 || pass.peeks > 0);
      if (midPass && !await _confirmSwitch(context, to)) return;
      await controller.switchTo(to);
    }

    /// Saves a tag change; on failure a snack bar explains and the screen
    /// keeps showing the saved state.
    Future<void> tag(Future<void> Function() action) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await action();
      } on InvalidCategoryNameException {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.categoryNameInvalid)),
        );
      } on Object {
        messenger.showSnackBar(SnackBar(content: Text(l10n.tagSaveFailed)));
      }
    }

    void onKey(VoidCallback action) {
      if (!_typing) action();
    }

    final reviewWord = view.isReview ? word : null;

    void onSummary(SummaryAction action) {
      switch (action) {
        case SummaryAction.startOther:
          controller.switchTo(view.direction.other);
        case SummaryAction.switchDirection:
          controller.switchTo(view.direction.other);
        case SummaryAction.repeat:
          controller.restart(view.direction);
        case SummaryAction.review:
          controller.restart(Direction.wd);
        case SummaryAction.nextPack:
          final next = view.nextPack!;
          context.go(
            learnPath(
              next.id,
              next.lastDirection ?? view.settings.defaultDirection,
            ),
          );
        case SummaryAction.back:
          context.go('/lists/${view.pack.wordlistId}');
      }
    }

    final title = l10n.learnPackTitle(
      view.pack.number,
      view.words.first.term,
      view.words.last.term,
    );

    final Widget content;
    if (pass == null || word == null) {
      final summary = Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 3,
        shape: wide
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(WpRadius.dialog),
              )
            : const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(WpRadius.sheet),
                ),
              ),
        child: Padding(
          padding: const EdgeInsets.all(WpSpace.xl),
          child: PassSummary(view: view, onAction: onSummary),
        ),
      );
      // Bottom sheet on phones, centred panel on wide screens; scrolls when
      // taller than the space (200 % text).
      content = Column(
        children: [
          _DirectionToggle(view: view, onChanged: onDirection),
          Expanded(
            child: Align(
              alignment: wide ? Alignment.center : Alignment.bottomCenter,
              child: SingleChildScrollView(
                padding: wide
                    ? const EdgeInsets.all(WpSpace.xl)
                    : EdgeInsets.zero,
                child: wide
                    ? ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: summary,
                      )
                    : SafeArea(top: false, child: summary),
              ),
            ),
          ),
        ],
      );
    } else {
      content = Column(
        children: [
          _DirectionToggle(view: view, onChanged: onDirection),
          _Progress(view: view),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: WpSpace.lg,
                vertical: WpSpace.md,
              ),
              child: Column(
                children: [
                  _Swipe(
                    onNext: onNext,
                    onPrevious: onPrevious,
                    child: WordCard(
                      key: ValueKey('card-${word.id}'),
                      word: word,
                      direction: view.direction,
                      revealed: pass.currentRevealed,
                      variant: view.isReview
                          ? WordCardVariant.review
                          : WordCardVariant.learn,
                      showPos: view.settings.showPos,
                      categoryPath: view.categoryPath(word, l10n.categoryPath),
                      onTap: onShow,
                    ),
                  ),
                  // Review only: in learning mode these are not built at all
                  // and nothing hints at them (D-9).
                  if (view.isReview) ...[
                    const SizedBox(height: WpSpace.lg),
                    QuickTagBar(
                      word: word,
                      onTone: (t) => tag(() => controller.setTone(word, t)),
                      onTrait: (t) =>
                          tag(() => controller.toggleTrait(word, t)),
                    ),
                    const SizedBox(height: WpSpace.md),
                    CategoryRow(
                      word: word,
                      categories: view.categories,
                      categoryFocus: _categoryFocus,
                      onAssign: (c, s) =>
                          tag(() => controller.assignCategory(word, c, s)),
                    ),
                  ],
                  if (pass.peeks > 0) ...[
                    const SizedBox(height: WpSpace.md),
                    Text(
                      l10n.learnPeekNote,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _Actions(
            canGoBack: pass.index > 0,
            shown: pass.currentRevealed,
            onPrevious: onPrevious,
            onShow: onShow,
            onNext: onNext,
          ),
        ],
      );
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () => onKey(onShow),
        const SingleActivator(LogicalKeyboardKey.enter): () => onKey(onShow),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            onKey(onNext),
        const SingleActivator(LogicalKeyboardKey.keyN): () => onKey(onNext),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            onKey(onPrevious),
        const SingleActivator(LogicalKeyboardKey.keyP): () => onKey(onPrevious),
        const SingleActivator(LogicalKeyboardKey.keyD): () =>
            onKey(() => onDirection(view.direction.other)),
        const SingleActivator(LogicalKeyboardKey.slash, shift: true): () =>
            onKey(() => showShortcutHelp(context)),
        // Review only (words of a Learned pack): 1–5 tag, C category.
        if (reviewWord != null) ...{
          for (final (i, t) in Tone.values.indexed)
            SingleActivator(_digits[i]): () =>
                onKey(() => tag(() => controller.tapTone(reviewWord, t))),
          for (final (i, t) in Trait.values.indexed)
            SingleActivator(_digits[3 + i]): () =>
                onKey(() => tag(() => controller.toggleTrait(reviewWord, t))),
          const SingleActivator(LogicalKeyboardKey.keyC): () =>
              onKey(_categoryFocus.requestFocus),
        },
      },
      child: Focus(
        autofocus: true,
        child: PageScaffold(
          title: title,
          actions: [if (view.isReview) const _ReviewBadge()],
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  static const _digits = [
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
  ];

  /// Fire-and-forget: feedback must never block or break an action.
  static void _haptic(Future<void> Function() feedback) {
    feedback().catchError((Object _) {});
  }

  Future<bool> _confirmSwitch(BuildContext context, Direction to) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Symbols.swap_horiz_rounded),
        title: Text(l10n.switchDirectionTitle(directionLabel(l10n, to))),
        content: Text(l10n.switchDirectionBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.switchDirectionConfirm),
          ),
        ],
      ),
    );
    return ok ?? false;
  }
}

class _ReviewBadge extends StatelessWidget {
  const _ReviewBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: WpSpace.md),
      child: Chip(
        avatar: Icon(
          Symbols.edit_note_rounded,
          size: 18,
          color: theme.colorScheme.onPrimaryContainer,
        ),
        label: Text(AppLocalizations.of(context).reviewBadge),
        backgroundColor: theme.colorScheme.primaryContainer,
        side: BorderSide.none,
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _DirectionToggle extends StatelessWidget {
  const _DirectionToggle({required this.view, required this.onChanged});

  final LearnView view;
  final ValueChanged<Direction> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wp = WpColors.of(context);

    Widget statusIcon(Mastery m) => switch (m) {
      Mastery.mastered => Icon(
        Symbols.check_circle_rounded,
        fill: 1,
        color: wp.statusLearned,
      ),
      Mastery.learning => Icon(
        Symbols.clock_loader_40_rounded,
        color: wp.statusLearning,
      ),
      Mastery.unseen => Icon(
        Symbols.radio_button_unchecked_rounded,
        color: wp.statusNew,
      ),
    };
    String masteryText(Mastery m) => switch (m) {
      Mastery.mastered => l10n.masteryMastered,
      Mastery.learning => l10n.masteryLearning,
      Mastery.unseen => l10n.masteryUnseen,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(WpSpace.lg, WpSpace.sm, WpSpace.lg, 0),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<Direction>(
          showSelectedIcon: false,
          segments: [
            for (final d in Direction.values)
              ButtonSegment(
                value: d,
                icon: statusIcon(view.progress.of(d)),
                tooltip: l10n.directionStatus(
                  directionLabel(l10n, d),
                  masteryText(view.progress.of(d)),
                ),
                label: Text(
                  d == Direction.wd
                      ? l10n.directionShortWd
                      : l10n.directionShortDw,
                ),
              ),
          ],
          selected: {view.direction},
          onSelectionChanged: (s) => onChanged(s.single),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.view});

  final LearnView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pass = view.pass!;
    final total = pass.wordIds.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(WpSpace.lg, WpSpace.md, WpSpace.lg, 0),
      child: Column(
        children: [
          Row(
            children: [
              Semantics(
                label: l10n.learnPositionSemantics(pass.index + 1, total),
                excludeSemantics: true,
                child: Text(
                  l10n.learnPosition(pass.index + 1, total),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: WpSpace.md),
              // Right-aligned; wraps instead of overflowing at large text.
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Symbols.visibility_rounded,
                      size: 18,
                      color: pass.peeks > 0
                          ? WpColors.of(context).statusLearning
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: WpSpace.xs),
                    Flexible(
                      child: Text(
                        l10n.learnPeeks(pass.peeks),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WpSpace.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(WpRadius.chip),
            child: LinearProgressIndicator(
              value: (pass.index + 1) / total,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.canGoBack,
    required this.shown,
    required this.onPrevious,
    required this.onShow,
    required this.onNext,
  });

  final bool canGoBack;
  final bool shown;
  final VoidCallback onPrevious;
  final VoidCallback onShow;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const tall = Size(WpSize.minTarget, WpSize.studyAction);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(WpSpace.md),
        child: Row(
          children: [
            IconButton(
              tooltip: l10n.learnPrevious,
              constraints: const BoxConstraints(
                minWidth: WpSize.studyAction,
                minHeight: WpSize.studyAction,
              ),
              onPressed: canGoBack ? onPrevious : null,
              icon: const Icon(Symbols.chevron_left_rounded),
            ),
            const SizedBox(width: WpSpace.sm),
            Expanded(
              child: FilledButton.tonalIcon(
                key: const ValueKey('show'),
                style: FilledButton.styleFrom(minimumSize: tall),
                onPressed: shown ? null : onShow,
                icon: Icon(
                  shown
                      ? Symbols.visibility_off_rounded
                      : Symbols.visibility_rounded,
                ),
                label: Text(shown ? l10n.learnShown : l10n.learnShow),
              ),
            ),
            const SizedBox(width: WpSpace.sm),
            Expanded(
              child: FilledButton.icon(
                key: const ValueKey('next'),
                style: FilledButton.styleFrom(minimumSize: tall),
                onPressed: onNext,
                iconAlignment: IconAlignment.end,
                icon: const Icon(Symbols.chevron_right_rounded),
                label: Text(l10n.learnNext),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Swipe left = Next, right = Previous (commit at 60 px or a fling).
class _Swipe extends StatefulWidget {
  const _Swipe({
    required this.onNext,
    required this.onPrevious,
    required this.child,
  });

  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Widget child;

  @override
  State<_Swipe> createState() => _SwipeState();
}

class _SwipeState extends State<_Swipe> {
  var _dx = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (_) => _dx = 0,
      onHorizontalDragUpdate: (d) => _dx += d.delta.dx,
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (_dx <= -60 || v < -700) widget.onNext();
        if (_dx >= 60 || v > 700) widget.onPrevious();
      },
      child: widget.child,
    );
  }
}
