import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/tree.dart';
import '../../l10n/app_localizations.dart';
import '../theme/wp_colors.dart';
import '../theme/wp_tokens.dart';
import '../tree/tree_view.dart';

/// The explorer tree with its search box: permanent side panel on wide
/// layouts, drawer content on narrow ones (`docs/UI_UX.md` §1, §8).
class TreePanel extends ConsumerStatefulWidget {
  const TreePanel({super.key});

  @override
  ConsumerState<TreePanel> createState() => _TreePanelState();
}

class _TreePanelState extends ConsumerState<TreePanel> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _submit(String text) {
    final q = text.trim();
    if (q.isNotEmpty) openNode(context, ref, NodeIds.search(q));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: WpColors.of(context).background,
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(WpSpace.md),
              child: TextField(
                key: const ValueKey('tree-search'),
                controller: _search,
                textInputAction: TextInputAction.search,
                onSubmitted: _submit,
                decoration: InputDecoration(
                  hintText: l10n.treeSearchHint,
                  prefixIcon: const Icon(Symbols.search_rounded),
                  isDense: true,
                ),
              ),
            ),
            const Expanded(child: TreeView()),
          ],
        ),
      ),
    );
  }
}
