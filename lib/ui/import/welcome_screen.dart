import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../common/page_scaffold.dart';
import '../theme/wp_icons.dart';
import '../theme/wp_tokens.dart';
import 'start_import.dart';

/// First launch, no wordlists yet (`docs/UI_UX.md` §2).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return PageScaffold(
      title: l10n.appTitle,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(WpSpace.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.welcomeTitle, style: theme.textTheme.displaySmall),
                const SizedBox(height: WpSpace.lg),
                Text(l10n.welcomeBody, style: theme.textTheme.bodyLarge),
                const SizedBox(height: WpSpace.xl),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(WpSize.studyAction),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(WpRadius.buttonLarge),
                    ),
                  ),
                  onPressed: () => startImport(context, ref),
                  icon: const Icon(WpIcons.uploadFile),
                  label: Text(l10n.welcomeImport),
                ),
                const SizedBox(height: WpSpace.lg),
                Text(
                  l10n.welcomeFormats,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
