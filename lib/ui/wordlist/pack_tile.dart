import 'package:flutter/material.dart';

import '../../data/repositories/pack_repo.dart';
import '../../domain/models.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import '../theme/wp_icons.dart';
import '../theme/wp_tokens.dart';

/// One pack in the wordlist grid: status icon + colour + label, never colour
/// alone.
class PackTile extends StatelessWidget {
  const PackTile({
    super.key,
    required this.row,
    required this.status,
    required this.onTap,
  });

  final PackRow row;
  final PackStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final style = statusStyle(context, status);
    final label = statusLabel(l10n, status);
    final number = row.pack.number;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: l10n.packSemantics(number, row.firstTerm, row.lastTerm, label),
      child: Material(
        color: style.background ?? theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WpRadius.packTile),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(WpSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      style.filled ? WpIcons.filled(style.icon) : style.icon,
                      color: style.color,
                      size: 20,
                    ),
                    const SizedBox(width: WpSpace.sm),
                    Expanded(
                      child: Text(
                        l10n.packTitle(number),
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WpSpace.xs),
                Text(
                  l10n.packRange(row.firstTerm, row.lastTerm),
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: WpSpace.xs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: style.color,
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
