import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/models.dart';
import '../../domain/tree.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/exceptions.dart';
import '../card/word_card.dart';
import '../common/page_scaffold.dart';
import '../common/shortcut_help.dart';
import '../shell/adaptive_shell.dart';
import '../tagging/category_row.dart';
import '../tagging/quick_tag_bar.dart';
import '../theme/wp_icons.dart';
import '../theme/wp_tokens.dart';
import '../tree/node_labels.dart';
import 'word_list_view.dart';

/// Browse the words of one tree node, one card at a time or as a list
/// (`docs/UI_UX.md` §4). Never changes learning status (EXP-4); words of
/// Learned packs can be tagged here (EXP-5).
class ExplorerScreen extends ConsumerStatefulWidget {
  const ExplorerScreen({super.key, this.nodeId});

  /// Tree node id (`docs/UI_UX.md` §8); null = nothing selected yet.
  final String? nodeId;

  @override
  ConsumerState<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends ConsumerState<ExplorerScreen> {
  final _pages = PageController();
  var _index = 0;
  var _revealed = false;

  /// Which side of the card shows first.
  var _side = Direction.wd;

  /// The node whose selection and tree path were last synced.
  String? _synced;

  @override
  void didUpdateWidget(ExplorerScreen old) {
    super.didUpdateWidget(old);
    if (old.nodeId != widget.nodeId) {
      _index = 0;
      _revealed = false;
      if (_pages.hasClients) _pages.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// A node opened by URL: select it and expand the tree down to it.
  void _sync(String nodeId, List<TreeNode> roots, UiStateData ui) {
    if (_synced == nodeId) return;
    final path = findPath(roots, nodeId);
    if (path.isEmpty && NodeIds.parse(nodeId)?.kind != NodeKind.search) return;
    _synced = nodeId;
    final repo = ref.read(uiStateRepoProvider);
    if (ui.selectedNodeId != nodeId) repo.setSelected(nodeId);
    // Expand the ancestors (a search node is not in the tree: none).
    final open = {
      ...ui.expandedNodeIds,
      for (final n
          in path.isEmpty
              ? const <TreeNode>[]
              : path.sublist(0, path.length - 1))
        n.id,
    };
    if (open.length != ui.expandedNodeIds.length) repo.setExpanded(open);
  }

  void _go(int index, int count) {
    if (count == 0) return;
    final i = index.clamp(0, count - 1);
    if (_pages.hasClients) {
      _pages.animateToPage(
        i,
        duration: MediaQuery.disableAnimationsOf(context)
            ? const Duration(milliseconds: 1)
            : const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
  }

  bool get _typing =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<EditableText>() !=
      null;

  Future<void> _tag(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } on InvalidCategoryNameException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.categoryNameInvalid)));
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.tagSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nodeId = widget.nodeId;
    if (nodeId == null) return _Choose(title: l10n.exploreTitle);

    final roots = ref.watch(treeProvider).value;
    final ui = ref.watch(uiStateProvider).value;
    final words = ref.watch(nodeWordsProvider(nodeId)).value;
    final learned = ref.watch(learnedPackIdsProvider).value ?? const {};
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final showPos = ref.watch(settingsProvider).value?.showPos ?? true;
    if (roots != null && ui != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sync(nodeId, roots, ui);
      });
    }

    final ref0 = NodeIds.parse(nodeId);
    final path = [
      for (final n in findPath(roots ?? const [], nodeId)) nodeTitle(l10n, n),
    ];
    // App bar: the node itself; the full breadcrumb wraps below it.
    final breadcrumb = ref0?.kind == NodeKind.search
        ? l10n.exploreSearchTitle(ref0!.query!)
        : path.join(' › ');
    final title = ref0?.kind == NodeKind.search || path.isEmpty
        ? breadcrumb
        : path.last;
    final listMode = ui?.viewerMode == 'list';

    if (words == null || ui == null) {
      return PageScaffold(
        title: title,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final count = words.length;
    if (_index >= count && count > 0) _index = count - 1;

    String? categoryPath(Word w) {
      String? name(String? id) =>
          categories.where((c) => c.id == id).firstOrNull?.name;
      final c = name(w.categoryId);
      final s = name(w.subcategoryId);
      return c == null ? null : (s == null ? c : l10n.categoryPath(c, s));
    }

    final tagging = ref.read(taggingServiceProvider);
    final Widget body;
    if (count == 0) {
      body = Center(
        child: Text(
          l10n.exploreEmpty,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    } else if (listMode) {
      body = WordListView(
        words: words,
        onOpen: (i) {
          setState(() {
            _index = i;
            _revealed = false;
          });
          ref.read(uiStateRepoProvider).setViewerMode('card');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pages.hasClients) _pages.jumpToPage(i);
          });
        },
      );
    } else {
      body = Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: count,
              onPageChanged: (i) => setState(() {
                _index = i;
                _revealed = false;
              }),
              itemBuilder: (context, i) {
                final w = words[i];
                final canCategorise = learned.contains(w.packId);
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(WpSpace.lg),
                  child: Column(
                    children: [
                      WordCard(
                        key: ValueKey('explore-${w.id}'),
                        word: w,
                        direction: _side,
                        revealed: i == _index && _revealed,
                        variant: WordCardVariant.browse,
                        showPos: showPos,
                        categoryPath: categoryPath(w),
                        onTap: () => setState(() => _revealed = !_revealed),
                      ),
                      const SizedBox(height: WpSpace.lg),
                      QuickTagBar(
                        word: w,
                        onTone: (t) => _tag(() => tagging.setTone(w.id, t)),
                        onTrait: (t) =>
                            _tag(() => tagging.toggleTrait(w.id, t)),
                      ),
                      if (canCategorise) ...[
                        const SizedBox(height: WpSpace.md),
                        CategoryRow(
                          word: w,
                          categories: categories,
                          onAssign: (c, s) => _tag(
                            () => tagging.assign(
                              w.id,
                              category: c,
                              subcategory: s,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(WpSpace.sm),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.learnPrevious,
                    onPressed: _index > 0 ? () => _go(_index - 1, count) : null,
                    icon: const Icon(WpIcons.chevronLeft),
                  ),
                  Expanded(
                    child: Semantics(
                      label: l10n.learnPositionSemantics(_index + 1, count),
                      excludeSemantics: true,
                      child: Text(
                        l10n.learnPosition(_index + 1, count),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.learnNext,
                    onPressed: _index < count - 1
                        ? () => _go(_index + 1, count)
                        : null,
                    icon: const Icon(WpIcons.chevronRight),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    void onKey(VoidCallback action) {
      if (!_typing) action();
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () =>
            onKey(() => setState(() => _revealed = !_revealed)),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            onKey(() => _go(_index + 1, count)),
        const SingleActivator(LogicalKeyboardKey.keyN): () =>
            onKey(() => _go(_index + 1, count)),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            onKey(() => _go(_index - 1, count)),
        const SingleActivator(LogicalKeyboardKey.keyP): () =>
            onKey(() => _go(_index - 1, count)),
        const SingleActivator(LogicalKeyboardKey.keyD): () =>
            onKey(() => setState(() => _side = _side.other)),
        const SingleActivator(LogicalKeyboardKey.slash, shift: true): () =>
            onKey(() => showShortcutHelp(context)),
      },
      child: Focus(
        autofocus: true,
        child: PageScaffold(
          title: title,
          actions: [
            IconButton(
              tooltip: _side == Direction.wd
                  ? l10n.exploreDefinitionFirst
                  : l10n.exploreWordFirst,
              icon: const Icon(WpIcons.swapHoriz),
              onPressed: () => setState(() {
                _side = _side.other;
                _revealed = false;
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(right: WpSpace.sm),
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: const Icon(WpIcons.style),
                    tooltip: l10n.exploreCardMode,
                  ),
                  ButtonSegment(
                    value: true,
                    icon: const Icon(WpIcons.list),
                    tooltip: l10n.exploreListMode,
                  ),
                ],
                selected: {listMode},
                onSelectionChanged: (s) => ref
                    .read(uiStateRepoProvider)
                    .setViewerMode(s.single ? 'list' : 'card'),
              ),
            ),
          ],
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  WpSpace.lg,
                  0,
                  WpSpace.lg,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (breadcrumb != title)
                      Text(
                        breadcrumb,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    Text(
                      l10n.homeWords(count),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

/// Explorer with no node selected.
class _Choose extends StatelessWidget {
  const _Choose({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shell = ShellScope.maybeOf(context);
    return PageScaffold(
      title: title,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(WpSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.exploreChooseNode,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (shell != null && shell.treeInDrawer) ...[
                const SizedBox(height: WpSpace.lg),
                FilledButton.icon(
                  onPressed: shell.openTree,
                  icon: const Icon(WpIcons.accountTree),
                  label: Text(l10n.treeOpen),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
