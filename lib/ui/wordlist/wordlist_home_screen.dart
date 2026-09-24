import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../data/db/database.dart';
import '../../data/repositories/pack_repo.dart';
import '../../domain/learning.dart';
import '../../domain/models.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../common/labels.dart';
import '../common/page_scaffold.dart';
import '../import/start_import.dart';
import '../theme/wp_tokens.dart';
import 'pack_tile.dart';

String learnPath(String packId, Direction d) => '/learn/$packId?dir=${d.name}';

/// Starting point for studying a wordlist (`docs/UI_UX.md` §2).
class WordlistHomeScreen extends ConsumerWidget {
  const WordlistHomeScreen({super.key, required this.wordlistId});

  final String wordlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final list = ref.watch(wordlistProvider(wordlistId)).value;
    final rows = ref.watch(packRowsProvider(wordlistId)).value;
    final passes = ref.watch(openPassesProvider(wordlistId)).value;
    final settings = ref.watch(settingsProvider).value;
    final lists = ref.watch(wordlistsProvider).value ?? const [];

    final ready =
        list != null && rows != null && passes != null && settings != null;
    return PageScaffold(
      title: list?.name ?? l10n.wordlistTitle,
      actions: [
        if (lists.length > 1)
          PopupMenuButton<String>(
            tooltip: l10n.switchWordlist,
            icon: const Icon(Symbols.swap_horiz_rounded),
            onSelected: (id) => context.go('/lists/$id'),
            itemBuilder: (context) => [
              for (final l in lists)
                CheckedPopupMenuItem(
                  value: l.id,
                  checked: l.id == wordlistId,
                  child: Text(l.name),
                ),
            ],
          ),
        IconButton(
          tooltip: l10n.welcomeImport,
          icon: const Icon(Symbols.add_rounded),
          onPressed: () => startImport(context, ref),
        ),
      ],
      body: ready
          ? _Body(list: list, rows: rows, passes: passes, settings: settings)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.list,
    required this.rows,
    required this.passes,
    required this.settings,
  });

  final Wordlist list;
  final List<PackRow> rows;
  final List<PassSession> passes;
  final AppSetting settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final rule = settings.learnedRule;
    final learned = rows
        .where((r) => r.status(rule) == PackStatus.learned)
        .length;
    final byId = {for (final r in rows) r.pack.id: r};

    final target = rows.isEmpty
        ? null
        : continueTarget(
            packs: [
              for (final r in rows)
                PackSummary(
                  id: r.pack.id,
                  number: r.pack.number,
                  progress: r.progress,
                ),
            ],
            openPasses: [
              for (final p in passes)
                OpenPassSummary(
                  packId: p.packId,
                  direction: p.direction,
                  updatedAt: p.updatedAt,
                ),
            ],
            rule: rule,
            defaultDirection: settings.defaultDirection,
          );

    final resume = passes.isEmpty
        ? null
        : passes.reduce((a, b) => b.updatedAt.isAfter(a.updatedAt) ? b : a);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(WpSpace.lg),
          sliver: SliverList.list(
            children: [
              Text(
                l10n.homeProgress(learned, rows.length),
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: WpSpace.xs),
              Text(
                l10n.homeWords(list.wordCount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: WpSpace.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(WpRadius.chip),
                child: LinearProgressIndicator(
                  value: rows.isEmpty ? 0 : learned / rows.length,
                  minHeight: 8,
                ),
              ),
              if (resume != null && byId[resume.packId] != null) ...[
                const SizedBox(height: WpSpace.lg),
                _ResumeBanner(pass: resume, row: byId[resume.packId]!),
              ],
              if (target != null) ...[
                const SizedBox(height: WpSpace.lg),
                _ContinueButton(target: target, byId: byId),
              ],
              const SizedBox(height: WpSpace.xl),
              Text(
                l10n.homePacks.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            WpSpace.lg,
            0,
            WpSpace.lg,
            WpSpace.xl,
          ),
          sliver: SliverGrid.builder(
            // Tiles grow with the text size (3 lines; must survive 200 %).
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              // Scale measured at the tiles' smallest text (13): Android
              // scales small text more than large text.
              mainAxisExtent: math.max(
                104,
                40 + 60 * MediaQuery.textScalerOf(context).scale(13) / 13,
              ),
              mainAxisSpacing: WpSpace.md,
              crossAxisSpacing: WpSpace.md,
            ),
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final r = rows[i];
              return PackTile(
                row: r,
                status: r.status(rule),
                onTap: () => context.go(
                  learnPath(
                    r.pack.id,
                    r.pack.lastDirection ??
                        neededDirection(r.progress, rule) ??
                        settings.defaultDirection,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.target, required this.byId});

  final ContinueTarget target;
  final Map<String, PackRow> byId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, path) = switch (target) {
      ContinuePack(:final packId, :final direction) => (
        l10n.continueLabel(
          byId[packId]!.pack.number,
          directionLabel(l10n, direction),
        ),
        learnPath(packId, direction),
      ),
      AllLearned(:final firstPackId) => (
        '${l10n.allLearned} · ${l10n.reviewPack(byId[firstPackId]!.pack.number)}',
        learnPath(firstPackId, Direction.wd),
      ),
    };
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(WpSize.studyAction),
        padding: const EdgeInsets.symmetric(
          horizontal: WpSpace.lg,
          vertical: WpSpace.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WpRadius.continueButton),
        ),
      ),
      onPressed: () => context.go(path),
      icon: const Icon(Symbols.school_rounded),
      label: Text(label, textAlign: TextAlign.center),
    );
  }
}

class _ResumeBanner extends StatelessWidget {
  const _ResumeBanner({required this.pass, required this.row});

  final PassSession pass;
  final PackRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(WpRadius.button),
      child: InkWell(
        borderRadius: BorderRadius.circular(WpRadius.button),
        onTap: () => context.go(learnPath(pass.packId, pass.direction)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: WpSize.minTarget),
          child: Padding(
            padding: const EdgeInsets.all(WpSpace.md),
            child: Row(
              children: [
                Icon(
                  Symbols.history_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: WpSpace.md),
                Expanded(
                  child: Text(
                    l10n.resumeLabel(
                      row.pack.number,
                      directionLabel(l10n, pass.direction),
                      pass.idx + 1,
                      row.wordCount,
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
