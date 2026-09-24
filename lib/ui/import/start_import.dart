import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/exceptions.dart';

/// Opens the file picker and, when a file is chosen, the import preview.
Future<void> startImport(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  try {
    final file = await ref.read(importFilePickerProvider).pick();
    if (file == null) return;
    ref.read(importDraftProvider.notifier).set(file);
    router.go('/import');
  } on ImportException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(importErrorText(l10n, e))));
  }
}

String importErrorText(AppLocalizations l10n, ImportException e) =>
    switch (e.error) {
      ImportError.tooLarge => l10n.importErrorTooLarge,
      ImportError.unreadable => l10n.importErrorUnreadable,
      ImportError.noWordsFound => l10n.importErrorNoWords,
    };
