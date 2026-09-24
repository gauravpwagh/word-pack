import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/wp_tokens.dart';

/// The `?` overlay listing keyboard shortcuts (`docs/UI_UX.md` §7).
Future<void> showShortcutHelp(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final rows = [
    ('Space / Enter', l10n.shortcutShow),
    ('→ / N', l10n.shortcutNext),
    ('← / P', l10n.shortcutPrevious),
    ('D', l10n.shortcutDirection),
    ('1 – 5', l10n.shortcutTags),
    ('C', l10n.shortcutCategory),
    ('Ctrl / ⌘ + F', l10n.treeSearchHint),
    ('?', l10n.shortcutHelp),
  ];
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.shortcutsTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (keys, what) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: WpSpace.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        keys,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    Expanded(child: Text(what)),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}
