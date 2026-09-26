import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/category_service.dart';
import '../../services/exceptions.dart';
import '../common/dialogs.dart';
import '../common/page_scaffold.dart';
import '../theme/wp_icons.dart';
import '../theme/wp_tokens.dart';

enum _Action { rename, merge, delete }

/// Tidy up categories: rename, merge, delete (CAT-7).
class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final usage = ref.watch(categoryUsageProvider).value;
    final Widget body;
    if (usage == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (usage.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(WpSpace.xl),
          child: Text(
            l10n.manageCategoriesEmpty,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    } else {
      final tops = usage.where((u) => u.category.parentId == null);
      body = ListView(
        padding: const EdgeInsets.only(bottom: WpSpace.xxl),
        children: [
          for (final top in tops) ...[
            _Row(item: top, all: usage, depth: 0),
            for (final sub in usage.where(
              (u) => u.category.parentId == top.category.id,
            ))
              _Row(item: sub, all: usage, depth: 1),
          ],
        ],
      );
    }
    return PageScaffold(title: l10n.settingsManageCategories, body: body);
  }
}

class _Row extends ConsumerWidget {
  const _Row({required this.item, required this.all, required this.depth});

  final CategoryUsage item;
  final List<CategoryUsage> all;
  final int depth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = item.category;
    return ListTile(
      contentPadding: EdgeInsets.only(
        left: WpSpace.lg + depth * WpSpace.xl,
        right: WpSpace.sm,
      ),
      leading: Icon(depth == 0 ? WpIcons.folder : WpIcons.label),
      title: Text(c.name),
      subtitle: Text(l10n.homeWords(item.words)),
      trailing: PopupMenuButton<_Action>(
        tooltip: c.name,
        onSelected: (a) => switch (a) {
          _Action.rename => _rename(context, ref),
          _Action.merge => _merge(context, ref),
          _Action.delete => _delete(context, ref),
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: _Action.rename, child: Text(l10n.rename)),
          PopupMenuItem(value: _Action.merge, child: Text(l10n.mergeInto)),
          PopupMenuItem(value: _Action.delete, child: Text(l10n.delete)),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final name = await promptText(
      context,
      title: l10n.renameCategory,
      label: l10n.categoryLabel,
      initial: item.category.name,
      maxLength: 80,
    );
    if (name == null || !context.mounted) return;
    try {
      await ref.read(categoryServiceProvider).rename(item.category.id, name);
    } on CategoryNameTakenException {
      if (context.mounted) _snack(context, l10n.categoryNameTaken(name.trim()));
    } on InvalidCategoryNameException {
      if (context.mounted) _snack(context, l10n.categoryNameInvalid);
    }
  }

  Future<void> _merge(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final c = item.category;
    final targets = [
      for (final u in all)
        if (u.category.id != c.id &&
            (u.category.parentId == null) == (c.parentId == null))
          u,
    ];
    final parentName = {for (final u in all) u.category.id: u.category.name};
    final target = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.mergeCategoryTitle(c.name)),
        children: [
          if (targets.isEmpty)
            Padding(
              padding: const EdgeInsets.all(WpSpace.xl),
              child: Text(l10n.mergeNoTargets),
            ),
          for (final t in targets)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, t.category.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: WpSpace.sm),
                child: Text(
                  t.category.parentId == null
                      ? t.category.name
                      : l10n.categoryPath(
                          parentName[t.category.parentId] ?? '',
                          t.category.name,
                        ),
                ),
              ),
            ),
        ],
      ),
    );
    if (target != null) {
      await ref.read(categoryServiceProvider).merge(c.id, target);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final c = item.category;
    final subs = all.where((u) => u.category.parentId == c.id).length;
    final ok = await confirm(
      context,
      icon: WpIcons.folderDelete,
      title: l10n.deleteCategoryTitle(c.name),
      body: c.parentId == null
          ? l10n.deleteCategoryBody(subs, item.words)
          : l10n.deleteSubcategoryBody(item.words),
      confirmLabel: l10n.deleteCategoryConfirm,
      destructive: true,
    );
    if (ok) await ref.read(categoryServiceProvider).delete(c.id);
  }
}
