import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/tree.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../shell/adaptive_shell.dart';
import '../theme/wp_tokens.dart';
import 'node_labels.dart';

/// Opens a tree node in the explorer and remembers the selection.
void openNode(BuildContext context, WidgetRef ref, String nodeId) {
  ref.read(uiStateRepoProvider).setSelected(nodeId);
  ShellScope.maybeOf(context)?.closeTree();
  context.go('/explore/${Uri.encodeComponent(nodeId)}');
}

/// The explorer tree as a flattened list of visible rows (fast for thousands
/// of nodes). Expansion and selection are saved in `UiState`.
class TreeView extends ConsumerStatefulWidget {
  const TreeView({super.key});

  @override
  ConsumerState<TreeView> createState() => _TreeViewState();
}

class _TreeViewState extends ConsumerState<TreeView> {
  final _focus = FocusNode(debugLabel: 'tree');

  /// Keyboard cursor (index into the visible rows) while the tree has focus.
  int _cursor = 0;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _toggle(Set<String> expanded, String id) {
    final next = {...expanded};
    next.contains(id) ? next.remove(id) : next.add(id);
    ref.read(uiStateRepoProvider).setExpanded(next);
  }

  KeyEventResult _onKey(
    KeyEvent event,
    List<TreeRow> rows,
    Set<String> expanded,
  ) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (rows.isEmpty) return KeyEventResult.ignored;
    final row = rows[_cursor.clamp(0, rows.length - 1)];
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      setState(() => _cursor = (_cursor + 1).clamp(0, rows.length - 1));
    } else if (key == LogicalKeyboardKey.arrowUp) {
      setState(() => _cursor = (_cursor - 1).clamp(0, rows.length - 1));
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (row.node.hasChildren && !row.expanded) _toggle(expanded, row.node.id);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (row.expanded) _toggle(expanded, row.node.id);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      openNode(context, ref, row.node.id);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final roots = ref.watch(treeProvider).value;
    final ui = ref.watch(uiStateProvider).value;
    if (roots == null || ui == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (roots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(WpSpace.xl),
          child: Text(
            l10n.treeEmpty,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final expanded = ui.expandedNodeIds.toSet();
    final rows = flattenTree(roots, expanded);
    final touch =
        MediaQuery.sizeOf(context).width < WpBreakpoints.expanded ||
        Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS;

    return Focus(
      focusNode: _focus,
      onFocusChange: (_) => setState(() {}),
      onKeyEvent: (_, e) => _onKey(e, rows, expanded),
      child: ListView.builder(
        itemCount: rows.length,
        itemExtent: touch ? WpSize.minTarget : 44,
        itemBuilder: (context, i) => _TreeRowTile(
          row: rows[i],
          selected: rows[i].node.id == ui.selectedNodeId,
          // The cursor outline is for keyboard use only, not after a touch.
          cursor:
              _focus.hasFocus &&
              i == _cursor &&
              FocusManager.instance.highlightMode ==
                  FocusHighlightMode.traditional,
          onOpen: () {
            // A tap also gives the tree keyboard focus (arrows, Enter).
            _focus.requestFocus();
            setState(() => _cursor = i);
            openNode(context, ref, rows[i].node.id);
          },
          onToggle: () {
            // Clicking an arrow puts the keyboard cursor on that row.
            _focus.requestFocus();
            setState(() => _cursor = i);
            _toggle(expanded, rows[i].node.id);
          },
        ),
      ),
    );
  }
}

class _TreeRowTile extends StatelessWidget {
  const _TreeRowTile({
    required this.row,
    required this.selected,
    required this.cursor,
    required this.onOpen,
    required this.onToggle,
  });

  final TreeRow row;
  final bool selected;
  final bool cursor;
  final VoidCallback onOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final n = row.node;
    final title = nodeTitle(l10n, n);
    final icon = nodeIcon(context, n, expanded: row.expanded);
    final count = n.kind == NodeKind.packs
        ? l10n.treeLearnedOfTotal(n.learned ?? 0, n.children.length)
        : '${n.count}';

    return Semantics(
      selected: selected,
      expanded: n.hasChildren ? row.expanded : null,
      child: Material(
        color: selected
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        shape: cursor
            ? RoundedRectangleBorder(
                side: BorderSide(color: theme.colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(WpRadius.chip),
              )
            : null,
        child: InkWell(
          onTap: onOpen,
          child: Row(
            children: [
              SizedBox(width: WpSpace.sm + row.depth * WpSpace.lg),
              SizedBox(
                width: WpSize.minTarget,
                child: n.hasChildren
                    ? IconButton(
                        tooltip: row.expanded
                            ? l10n.treeCollapseNode(title)
                            : l10n.treeExpandNode(title),
                        onPressed: onToggle,
                        icon: Icon(
                          row.expanded
                              ? Symbols.expand_more_rounded
                              : Symbols.chevron_right_rounded,
                        ),
                      )
                    : null,
              ),
              Icon(
                icon.icon,
                size: 20,
                fill: icon.filled ? 1 : 0,
                color: icon.color ?? theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: WpSpace.sm),
              Expanded(
                child: Semantics(
                  label: l10n.treeRowSemantics(title, n.count),
                  excludeSemantics: true,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: n.kind == NodeKind.wordlist
                        ? theme.textTheme.titleSmall
                        : theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              ExcludeSemantics(
                child: Text(
                  count,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (n.kind == NodeKind.pack)
                IconButton(
                  tooltip: l10n.treeStudyPack(n.packNumber!),
                  icon: const Icon(Symbols.school_rounded, size: 20),
                  onPressed: () {
                    ShellScope.maybeOf(context)?.closeTree();
                    // No direction: the pack's last one, else the one needed.
                    context.go('/learn/${n.id.substring('pack:'.length)}');
                  },
                )
              else
                const SizedBox(width: WpSpace.md),
            ],
          ),
        ),
      ),
    );
  }
}
