import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../domain/tree.dart';
import '../../l10n/app_localizations.dart';
import '../card/tag_style.dart';
import '../common/labels.dart';
import '../theme/wp_colors.dart';
import '../theme/wp_icons.dart';

/// Display text for a tree node.
String nodeTitle(AppLocalizations l10n, TreeNode n) => switch (n.kind) {
  NodeKind.wordlist ||
  NodeKind.category ||
  NodeKind.subcategory => n.name ?? '',
  NodeKind.packs => l10n.treePacks,
  NodeKind.pack => l10n.packTitle(n.packNumber!),
  NodeKind.categories => l10n.treeCategories,
  NodeKind.noSubcategory => l10n.treeNoSubcategory,
  NodeKind.uncategorised => l10n.treeUncategorised,
  NodeKind.tags => l10n.treeTags,
  NodeKind.tag => tagTitle(l10n, n.tagKey!),
  NodeKind.search => '',
};

String tagTitle(AppLocalizations l10n, String key) => switch (key) {
  'positive' => l10n.tonePositive,
  'negative' => l10n.toneNegative,
  'neutral' => l10n.toneNeutral,
  'counterIntuitive' => l10n.traitCounterIntuitive,
  'multipleMeanings' => l10n.traitMultipleMeanings,
  _ => l10n.tagUntagged,
};

/// Icon, fill and colour for a node (`docs/UI_UX.md` §8, §9).
({IconData icon, bool filled, Color? color}) nodeIcon(
  BuildContext context,
  TreeNode n, {
  required bool expanded,
}) {
  final wp = WpColors.of(context);
  switch (n.kind) {
    case NodeKind.pack:
      final s = statusStyle(context, n.status ?? PackStatus.newPack);
      return (icon: s.icon, filled: s.filled, color: s.color);
    case NodeKind.tag:
      final key = n.tagKey!;
      for (final t in Tone.values) {
        if (t.name == key) {
          return (
            icon: TagStyle.toneIcon(t),
            filled: false,
            color: TagStyle.toneColor(wp, t),
          );
        }
      }
      for (final t in Trait.values) {
        if (t.name == key) {
          return (
            icon: TagStyle.traitIcon(t),
            filled: false,
            color: TagStyle.traitColor(wp, t),
          );
        }
      }
      return (icon: WpIcons.sell, filled: false, color: wp.statusNew);
    default:
      final icon = switch (n.kind) {
        NodeKind.wordlist => WpIcons.menuBook,
        NodeKind.packs => WpIcons.stacks,
        NodeKind.categories => WpIcons.folderCopy,
        NodeKind.category => expanded ? WpIcons.folderOpen : WpIcons.folder,
        NodeKind.subcategory => WpIcons.label,
        NodeKind.noSubcategory || NodeKind.uncategorised => WpIcons.labelOff,
        NodeKind.tags => WpIcons.sell,
        _ => WpIcons.search,
      };
      return (icon: icon, filled: false, color: null);
  }
}
