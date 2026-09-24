import 'package:flutter/material.dart';

import '../../domain/pos.dart';
import '../theme/wp_text.dart';
import '../theme/wp_tokens.dart';

/// Part-of-speech label (`noun`, `adj.`, …) with the full name for tooltips
/// and screen readers (`docs/IMPORT_FORMAT.md` §5).
class PosChip extends StatelessWidget {
  const PosChip({super.key, required this.pos, required this.posRaw});

  final String? pos;
  final String? posRaw;

  @override
  Widget build(BuildContext context) {
    final label = posLabel(pos, posRaw);
    if (label == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final full = posFullName(pos, posRaw)!;
    // Screen readers announce the full name ("adjective"), not "adj.".
    return Semantics(
      label: full,
      excludeSemantics: true,
      child: Tooltip(
        message: full,
        excludeFromSemantics: true,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: WpSpace.sm,
            vertical: WpSpace.xs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(WpRadius.chip),
          ),
          child: Text(
            label,
            style: WpText.of(
              context,
            ).posChip.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
