import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/db/database.dart';
import '../../domain/models.dart';
import '../../domain/packing.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/backup_service.dart';
import '../common/dialogs.dart';
import '../common/labels.dart';
import '../common/page_scaffold.dart';
import '../common/shortcut_help.dart';
import '../theme/wp_icons.dart';
import '../theme/wp_tokens.dart';

/// Settings (`docs/REQUIREMENTS.md` §6), categories, wordlists and backup.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider).value;
    final lists = ref.watch(wordlistsProvider).value ?? const [];
    final service = ref.read(settingsServiceProvider);
    if (settings == null) {
      return PageScaffold(
        title: l10n.settingsTitle,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    String ruleText(LearnedRule r) => switch (r) {
      LearnedRule.both => l10n.ruleBoth,
      LearnedRule.either => l10n.ruleEither,
      LearnedRule.wdOnly => l10n.ruleWdOnly,
      LearnedRule.dwOnly => l10n.ruleDwOnly,
    };

    return PageScaffold(
      title: l10n.settingsTitle,
      body: ListView(
        padding: const EdgeInsets.only(bottom: WpSpace.xxl),
        children: [
          _Header(l10n.settingsLearning),
          ListTile(
            leading: const Icon(WpIcons.stacks),
            title: Text(l10n.settingsPackSize),
            subtitle: Text(l10n.settingsPackSizeValue(settings.packSize)),
            onTap: () => _changePackSize(context, ref, settings.packSize),
          ),
          _Labeled(
            label: l10n.settingsDefaultDirection,
            child: SegmentedButton<Direction>(
              segments: [
                for (final d in Direction.values)
                  ButtonSegment(value: d, label: Text(directionLabel(l10n, d))),
              ],
              selected: {settings.defaultDirection},
              onSelectionChanged: (s) => service.setDefaultDirection(s.single),
            ),
          ),
          _Labeled(
            label: l10n.settingsLearnedRule,
            child: RadioGroup<LearnedRule>(
              groupValue: settings.learnedRule,
              onChanged: (r) {
                if (r != null) service.setLearnedRule(r);
              },
              child: Column(
                children: [
                  for (final r in LearnedRule.values)
                    RadioListTile<LearnedRule>(
                      value: r,
                      contentPadding: EdgeInsets.zero,
                      title: Text(ruleText(r)),
                    ),
                ],
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(WpIcons.sell),
            title: Text(l10n.settingsShowPos),
            value: settings.showPos,
            onChanged: service.setShowPos,
          ),
          SwitchListTile(
            secondary: const Icon(WpIcons.visibility),
            title: Text(l10n.settingsDemote),
            subtitle: Text(l10n.settingsDemoteHint),
            value: settings.demoteOnReveal,
            onChanged: service.setDemoteOnReveal,
          ),
          _Header(l10n.settingsAppearance),
          _Labeled(
            label: l10n.settingsTheme,
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'system', label: Text(l10n.themeSystem)),
                ButtonSegment(value: 'light', label: Text(l10n.themeLight)),
                ButtonSegment(value: 'dark', label: Text(l10n.themeDark)),
              ],
              selected: {settings.theme},
              onSelectionChanged: (s) => service.setTheme(s.single),
            ),
          ),
          _Header(l10n.settingsOrganise),
          ListTile(
            leading: const Icon(WpIcons.folderCopy),
            title: Text(l10n.settingsManageCategories),
            trailing: const Icon(WpIcons.chevronRight),
            onTap: () => context.go('/settings/categories'),
          ),
          if (lists.isNotEmpty) _Header(l10n.settingsWordlists),
          for (final list in lists) _WordlistTile(list: list),
          _Header(l10n.settingsBackup),
          ListTile(
            leading: const Icon(WpIcons.download),
            title: Text(l10n.settingsExport),
            subtitle: Text(l10n.settingsExportHint),
            onTap: () => _export(context, ref),
          ),
          ListTile(
            leading: const Icon(WpIcons.settingsBackupRestore),
            title: Text(l10n.settingsRestore),
            subtitle: Text(l10n.settingsRestoreHint),
            onTap: () => _restore(context, ref),
          ),
          ListTile(
            leading: const Icon(WpIcons.keyboard),
            title: Text(l10n.settingsKeyboard),
            onTap: () => showShortcutHelp(context),
          ),
        ],
      ),
    );
  }

  Future<void> _changePackSize(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final size = await showDialog<int>(
      context: context,
      builder: (_) => _PackSizeDialog(initial: current),
    );
    if (size == null || size == current || !context.mounted) return;
    final service = ref.read(settingsServiceProvider);
    final preview = await service.previewPackSizeChange(size);
    if (!context.mounted) return;
    final body = [
      l10n.packSizeBody(size),
      for (final w in preview.wordlists)
        l10n.packSizeList(w.name, w.before, w.after),
      if (preview.openPasses > 0) l10n.packSizeOpenPasses(preview.openPasses),
    ].join('\n\n');
    final ok = await confirm(
      context,
      icon: WpIcons.viewModule,
      title: l10n.packSizeTitle(size),
      body: body,
      confirmLabel: l10n.packSizeConfirm,
    );
    if (ok) await service.applyPackSizeChange(size);
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final backup = ref.read(backupServiceProvider);
    try {
      final saved = await ref
          .read(backupFilesProvider)
          .save(backup.fileName(), await backup.export());
      if (saved) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.exportDone)));
      }
    } on Object {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.exportFailed)));
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final backup = ref.read(backupServiceProvider);
    final json = await ref.read(backupFilesProvider).open();
    if (json == null || !context.mounted) return;
    final BackupInfo info;
    try {
      info = backup.inspect(json);
    } on BackupFormatException {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.restoreInvalid)));
      return;
    }
    final ok = await confirm(
      context,
      icon: WpIcons.settingsBackupRestore,
      title: l10n.restoreTitle,
      body: l10n.restoreBody(
        info.wordlists,
        info.words,
        DateFormat.yMMMd().format(info.exportedAt.toLocal()),
      ),
      confirmLabel: l10n.restoreConfirm,
      destructive: true,
    );
    if (!ok) return;
    try {
      await backup.restore(json);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.restoreDone)));
    } on BackupFormatException {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.restoreInvalid)));
    }
  }
}

class _WordlistTile extends ConsumerWidget {
  const _WordlistTile({required this.list});

  final Wordlist list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(wordlistServiceProvider);
    return ListTile(
      leading: const Icon(WpIcons.menuBook),
      title: Text(list.name),
      subtitle: Text(l10n.homeWords(list.wordCount)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.rename,
            icon: const Icon(WpIcons.edit),
            onPressed: () async {
              final name = await promptText(
                context,
                title: l10n.renameWordlist,
                label: l10n.importNameLabel,
                initial: list.name,
              );
              if (name != null) await service.rename(list.id, name);
            },
          ),
          IconButton(
            tooltip: l10n.delete,
            icon: const Icon(WpIcons.delete),
            onPressed: () async {
              final packs = await ref
                  .read(packRepoProvider)
                  .forWordlist(list.id);
              if (!context.mounted) return;
              final ok = await confirm(
                context,
                icon: WpIcons.delete,
                title: l10n.deleteWordlistTitle(list.name),
                body: l10n.deleteWordlistBody(list.wordCount, packs.length),
                confirmLabel: l10n.deleteWordlistConfirm,
                destructive: true,
              );
              if (ok) await service.delete(list.id);
            },
          ),
        ],
      ),
    );
  }
}

class _PackSizeDialog extends StatefulWidget {
  const _PackSizeDialog({required this.initial});

  final int initial;

  @override
  State<_PackSizeDialog> createState() => _PackSizeDialogState();
}

class _PackSizeDialogState extends State<_PackSizeDialog> {
  late int _size = widget.initial;

  void _set(int v) => setState(() => _size = v.clamp(minPackSize, maxPackSize));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.settingsPackSize),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: '−',
                onPressed: () => _set(_size - 1),
                icon: const Icon(WpIcons.remove),
              ),
              SizedBox(
                width: 72,
                child: Text(
                  '$_size',
                  key: const ValueKey('pack-size-value'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              IconButton(
                tooltip: '+',
                onPressed: () => _set(_size + 1),
                icon: const Icon(WpIcons.add),
              ),
            ],
          ),
          Slider(
            value: _size.toDouble(),
            min: minPackSize.toDouble(),
            max: maxPackSize.toDouble(),
            divisions: maxPackSize - minPackSize,
            label: '$_size',
            semanticFormatterCallback: (v) =>
                l10n.settingsPackSizeValue(v.round()),
            onChanged: (v) => _set(v.round()),
          ),
          Text(l10n.settingsPackSizeHint),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _size),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        WpSpace.lg,
        WpSpace.xl,
        WpSpace.lg,
        WpSpace.sm,
      ),
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        WpSpace.lg,
        WpSpace.md,
        WpSpace.lg,
        WpSpace.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: WpSpace.sm),
          child,
        ],
      ),
    );
  }
}
