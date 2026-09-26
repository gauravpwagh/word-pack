import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/importer.dart';
import '../../domain/pos.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/exceptions.dart';
import '../../services/file_picking.dart';
import '../../services/import_service.dart';
import '../common/page_scaffold.dart';
import '../theme/wp_colors.dart';
import '../theme/wp_icons.dart';
import '../theme/wp_text.dart';
import '../theme/wp_tokens.dart';
import 'start_import.dart';

/// Check the file before saving (`docs/IMPORT_FORMAT.md` §8). Nothing is
/// saved until Import is pressed.
class ImportPreviewScreen extends ConsumerWidget {
  const ImportPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(importDraftProvider);
    final preview = ref.watch(importPreviewProvider);

    final Widget body;
    if (draft == null) {
      body = _Centered(
        child: FilledButton.icon(
          onPressed: () => startImport(context, ref),
          icon: const Icon(WpIcons.uploadFile),
          label: Text(l10n.importChooseFile),
        ),
      );
    } else {
      body = switch (preview) {
        AsyncData(value: final report?) => _Preview(
          key: ValueKey(draft),
          draft: draft,
          report: report,
        ),
        AsyncError(:final error) => _Centered(
          child: _ErrorBody(
            message: error is ImportException
                ? importErrorText(l10n, error)
                : l10n.importFailed,
          ),
        ),
        _ => _Centered(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: WpSpace.lg),
              Text(l10n.importReading(draft.name)),
            ],
          ),
        ),
      };
    }
    return PageScaffold(title: l10n.importTitle, body: body);
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(WpSpace.xl),
      child: child,
    ),
  );
}

class _ErrorBody extends ConsumerWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(WpIcons.error, size: 40, color: theme.colorScheme.error),
          const SizedBox(height: WpSpace.lg),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: WpSpace.xl),
          FilledButton(
            onPressed: () => startImport(context, ref),
            child: Text(AppLocalizations.of(context).importChooseAnother),
          ),
        ],
      ),
    );
  }
}

class _Preview extends ConsumerStatefulWidget {
  const _Preview({super.key, required this.draft, required this.report});

  final PickedFile draft;
  final ImportReport report;

  @override
  ConsumerState<_Preview> createState() => _PreviewState();
}

class _PreviewState extends ConsumerState<_Preview> {
  late final _name = TextEditingController(
    text: defaultWordlistName(widget.draft.name),
  );
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(importServiceProvider)
          .commit(
            widget.report,
            name: _name.text,
            sourceFilename: widget.draft.name,
          );
      ref.read(importDraftProvider.notifier).clear();
      router.go('/lists/$id');
    } on Object {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed)));
    }
  }

  void _cancel() {
    ref.read(importDraftProvider.notifier).clear();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final wp = WpColors.of(context);
    final report = widget.report;
    final settings = ref.watch(settingsProvider).value;
    final packSize = settings?.packSize ?? 30;
    final words = report.words.length;
    final packs = (words + packSize - 1) ~/ packSize;
    final last = words - (packs - 1) * packSize;

    final posSummary = [
      for (final MapEntry(key: key, value: n) in report.posCounts.entries)
        '${posLabel(key, key)} $n',
    ].join(' · ');

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(WpSpace.lg),
            children: [
              Text(
                l10n.importFile(widget.draft.name),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: WpSpace.xs),
              Text(
                report.format == ImportFormat.dash
                    ? l10n.importDetectedDash
                    : l10n.importDetectedColumns,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: WpSpace.lg),
              TextField(
                controller: _name,
                maxLength: 200,
                decoration: InputDecoration(labelText: l10n.importNameLabel),
              ),
              const SizedBox(height: WpSpace.sm),
              _Fact(
                icon: WpIcons.checkCircle,
                color: wp.statusLearned,
                text: l10n.importWordsReady(words),
                detail: posSummary.isEmpty ? null : posSummary,
              ),
              _Fact(
                icon: WpIcons.warning,
                color: report.skipped.isEmpty
                    ? wp.textTertiary
                    : wp.statusLearning,
                text: l10n.importSkipped(report.skipped.length),
              ),
              for (final s in report.skipped)
                Padding(
                  padding: const EdgeInsets.only(left: 36, bottom: WpSpace.xs),
                  child: Text(
                    l10n.importSkippedLine(
                      s.line,
                      s.text.trim(),
                      switch (s.reason) {
                        SkipReason.noSeparator => l10n.skipNoSeparator,
                        SkipReason.emptyTerm => l10n.skipEmptyTerm,
                        SkipReason.emptyDefinition => l10n.skipEmptyDefinition,
                      },
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              _Fact(
                icon: WpIcons.info,
                color: wp.textTertiary,
                text: l10n.importDuplicates(report.duplicatesRemoved),
              ),
              _Fact(
                icon: WpIcons.stacks,
                color: theme.colorScheme.primary,
                text: last == packSize
                    ? l10n.importPacks(packs, packSize)
                    : l10n.importPacksLast(packs, packSize, last),
              ),
              const SizedBox(height: WpSpace.lg),
              Text(
                l10n.importFirstWords.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: WpSpace.sm),
              for (final w in report.words.take(10)) _WordRow(word: w),
            ],
          ),
        ),
        Material(
          color: theme.colorScheme.surface,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(WpSpace.md),
              // Stacks the buttons when they don't fit (narrow, 200 % text).
              child: OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                spacing: WpSpace.sm,
                overflowSpacing: WpSpace.sm,
                overflowAlignment: OverflowBarAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving ? null : _cancel,
                    child: Text(l10n.importCancel),
                  ),
                  FilledButton(
                    onPressed: _saving ? null : _import,
                    child: Text(l10n.importConfirm(words)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.icon,
    required this.color,
    required this.text,
    this.detail,
  });

  final IconData icon;
  final Color color;
  final String text;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: WpSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: WpSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: theme.textTheme.bodyLarge),
                if (detail != null)
                  Text(
                    detail!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WordRow extends StatelessWidget {
  const _WordRow({required this.word});

  final ImportedWord word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = WpText.of(context);
    final label = posLabel(word.pos, word.posRaw);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: WpSpace.xs),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: word.term,
              style: text.cardAnswer.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (label != null)
              TextSpan(
                text: '  $label',
                style: text.posChip.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                semanticsLabel: ' ${posFullName(word.pos, word.posRaw)}',
              ),
            TextSpan(
              text: '  ${word.definition}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
