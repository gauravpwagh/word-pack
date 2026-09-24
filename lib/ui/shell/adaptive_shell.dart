import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../theme/wp_tokens.dart';
import 'tree_panel.dart';
import 'tree_panel_state.dart';

/// Top-level sections. The bottom bar (phones) shows all but Import, which is
/// reached from the wordlist home there (`docs/UI_UX.md` §1).
enum AppSection {
  learn('/', Symbols.school_rounded),
  explore('/explore', Symbols.account_tree_rounded),
  import('/import', Symbols.upload_file_rounded),
  settings('/settings', Symbols.settings_rounded);

  const AppSection(this.path, this.icon);

  final String path;
  final IconData icon;

  bool get onBottomBar => this != AppSection.import;

  String label(AppLocalizations l10n) => switch (this) {
    AppSection.learn => l10n.navLearn,
    AppSection.explore => l10n.navExplore,
    AppSection.import => l10n.navImport,
    AppSection.settings => l10n.navSettings,
  };

  static AppSection forLocation(String location) {
    for (final s in [explore, import, settings]) {
      if (location == s.path || location.startsWith('${s.path}/')) return s;
    }
    return learn;
  }
}

/// Lets a screen's app bar open the tree drawer on narrow layouts.
class ShellScope extends InheritedWidget {
  const ShellScope({
    super.key,
    required this.treeInDrawer,
    required this.openTree,
    required this.closeTree,
    required super.child,
  });

  final bool treeInDrawer;
  final VoidCallback openTree;

  /// Closes the drawer after a tree selection (no-op with a permanent tree).
  final VoidCallback closeTree;

  static ShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellScope>();

  @override
  bool updateShouldNotify(ShellScope oldWidget) =>
      treeInDrawer != oldWidget.treeInDrawer;
}

/// Navigation frame around every screen, adapted to the window width:
/// < 600 bottom bar + tree drawer; 600–839 rail + tree drawer;
/// ≥ 840 rail + permanent, resizable tree panel.
class AdaptiveShell extends StatefulWidget {
  const AdaptiveShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  State<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends State<AdaptiveShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final current = AppSection.forLocation(widget.location);
    final compact = width < WpBreakpoints.medium;
    final expanded = width >= WpBreakpoints.expanded;

    final Widget body;
    if (compact) {
      body = widget.child;
    } else {
      final rail = NavigationRail(
        labelType: NavigationRailLabelType.all,
        selectedIndex: current.index,
        onDestinationSelected: (i) => context.go(AppSection.values[i].path),
        destinations: [
          for (final s in AppSection.values)
            NavigationRailDestination(
              icon: Icon(s.icon),
              selectedIcon: Icon(s.icon, fill: 1),
              label: Text(s.label(l10n)),
            ),
        ],
      );
      body = Row(
        children: [
          SafeArea(right: false, child: rail),
          const VerticalDivider(width: 1),
          if (expanded) const _PermanentTreePanel(),
          Expanded(child: widget.child),
        ],
      );
    }

    final bottomSections = AppSection.values.where((s) => s.onBottomBar);
    return ShellScope(
      treeInDrawer: !expanded,
      openTree: () => _scaffoldKey.currentState?.openDrawer(),
      closeTree: () {
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          _scaffoldKey.currentState!.closeDrawer();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: expanded ? null : const Drawer(child: TreePanel()),
        body: body,
        bottomNavigationBar: compact
            ? NavigationBar(
                selectedIndex: bottomSections.toList().indexOf(
                  current.onBottomBar ? current : AppSection.learn,
                ),
                onDestinationSelected: (i) =>
                    context.go(bottomSections.elementAt(i).path),
                destinations: [
                  for (final s in bottomSections)
                    NavigationDestination(
                      icon: Icon(s.icon),
                      selectedIcon: Icon(s.icon, fill: 1),
                      label: s.label(l10n),
                    ),
                ],
              )
            : null,
      ),
    );
  }
}

class _PermanentTreePanel extends ConsumerWidget {
  const _PermanentTreePanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final panel = ref.watch(treePanelProvider);
    final controller = ref.read(treePanelProvider.notifier);
    // Open/closed is saved in UiState; the width is kept for the session.
    final open = ref.watch(uiStateProvider).value?.treePanelOpen ?? true;
    void toggle() => ref.read(uiStateRepoProvider).setTreePanelOpen(!open);

    if (!open) {
      return Column(
        children: [
          IconButton(
            tooltip: l10n.treeExpand,
            icon: const Icon(Symbols.left_panel_open_rounded),
            onPressed: toggle,
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(
          width: panel.width,
          child: Stack(
            children: [
              const Positioned.fill(child: TreePanel()),
              Positioned(
                right: 0,
                bottom: WpSpace.sm,
                child: IconButton(
                  tooltip: l10n.treeCollapse,
                  icon: const Icon(Symbols.left_panel_close_rounded),
                  onPressed: toggle,
                ),
              ),
            ],
          ),
        ),
        Semantics(
          label: l10n.treeResize,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) => controller.resizeBy(d.delta.dx),
              child: const SizedBox(
                width: WpSpace.sm,
                child: VerticalDivider(width: WpSpace.sm),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
