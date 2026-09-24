import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/wp_colors.dart';

/// A confirmation dialog; destructive ones use the negative colour and say
/// exactly what goes. True when confirmed.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  IconData? icon,
  bool destructive = false,
}) async {
  final l10n = AppLocalizations.of(context);
  final negative = WpColors.of(context).negative;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: icon == null
          ? null
          : Icon(icon, color: destructive ? negative : null),
      title: Text(title),
      content: SingleChildScrollView(child: Text(body)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: negative,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                )
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Asks for a name; null if cancelled.
Future<String?> promptText(
  BuildContext context, {
  required String title,
  required String label,
  String initial = '',
  int maxLength = 200,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _PromptDialog(
      title: title,
      label: label,
      initial: initial,
      maxLength: maxLength,
    ),
  );
}

class _PromptDialog extends StatefulWidget {
  const _PromptDialog({
    required this.title,
    required this.label,
    required this.initial,
    required this.maxLength,
  });

  final String title;
  final String label;
  final String initial;
  final int maxLength;

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    if (_text.text.trim().isNotEmpty) Navigator.pop(context, _text.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const ValueKey('prompt-field'),
        controller: _text,
        autofocus: true,
        maxLength: widget.maxLength,
        decoration: InputDecoration(labelText: widget.label),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}
