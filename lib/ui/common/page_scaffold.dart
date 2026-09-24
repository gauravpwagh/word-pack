import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/app_localizations.dart';
import '../shell/adaptive_shell.dart';

/// Scaffold for a screen inside [AdaptiveShell]. Adds the ☰ button that opens
/// the tree drawer when the tree is not permanently visible.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final shell = ShellScope.maybeOf(context);
    final showTreeButton = shell != null && shell.treeInDrawer;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        automaticallyImplyLeading: !showTreeButton,
        leading: showTreeButton
            ? IconButton(
                tooltip: AppLocalizations.of(context).treeOpen,
                icon: const Icon(Symbols.menu_rounded),
                onPressed: shell.openTree,
              )
            : null,
      ),
      body: body,
    );
  }
}
