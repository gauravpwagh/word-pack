import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../data/db/database.dart';
import '../../domain/categories.dart';
import '../../l10n/app_localizations.dart';
import '../theme/wp_tokens.dart';

/// Category + subcategory comboboxes (`docs/UI_UX.md` §5, CAT-3 … CAT-5).
/// Typing filters existing names case-insensitively; without an exact match
/// the last option is `Create "…"`. Subcategory is disabled until a category
/// is chosen. Saves on selection.
class CategoryRow extends StatelessWidget {
  const CategoryRow({
    super.key,
    required this.word,
    required this.categories,
    required this.onAssign,
    this.categoryFocus,
  });

  final Word word;

  /// All categories and subcategories (shared across wordlists).
  final List<Category> categories;

  /// Saves the chosen names; a null category clears both.
  final void Function(String? category, String? subcategory) onAssign;

  /// Focused by the `C` shortcut.
  final FocusNode? categoryFocus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final byId = {for (final c in categories) c.id: c};
    final category = byId[word.categoryId];
    final subcategory = byId[word.subcategoryId];
    final tops = [
      for (final c in categories)
        if (c.parentId == null) c.name,
    ];
    final subs = category == null
        ? const <String>[]
        : [
            for (final c in categories)
              if (c.parentId == category.id) c.name,
          ];

    final categoryField = _NameField(
      fieldKey: const ValueKey('category-field'),
      label: l10n.categoryLabel,
      clearTooltip: l10n.categoryClear,
      value: category?.name,
      options: tops,
      focusNode: categoryFocus,
      onChosen: (name) => onAssign(name, null),
      onCleared: () => onAssign(null, null),
    );
    final subcategoryField = _NameField(
      fieldKey: const ValueKey('subcategory-field'),
      label: l10n.subcategoryLabel,
      clearTooltip: l10n.subcategoryClear,
      value: subcategory?.name,
      options: subs,
      enabled: category != null,
      onChosen: (name) => onAssign(category!.name, name),
      onCleared: () => onAssign(category!.name, null),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return Column(
            children: [
              categoryField,
              const SizedBox(height: WpSpace.sm),
              subcategoryField,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: categoryField),
            const SizedBox(width: WpSpace.md),
            Expanded(child: subcategoryField),
          ],
        );
      },
    );
  }
}

/// An option in the suggestion list: an existing name, or "create".
class _Option {
  const _Option(this.name, {this.create = false});

  final String name;
  final bool create;
}

class _NameField extends StatefulWidget {
  const _NameField({
    required this.fieldKey,
    required this.label,
    required this.clearTooltip,
    required this.value,
    required this.options,
    required this.onChosen,
    required this.onCleared,
    this.enabled = true,
    this.focusNode,
  });

  final Key fieldKey;
  final String label;
  final String clearTooltip;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChosen;
  final VoidCallback onCleared;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final _controller = TextEditingController(text: widget.value ?? '');
  FocusNode? _ownFocus;

  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  /// The saved value changed (another word, or a save): show it, unless the
  /// user is typing here.
  @override
  void didUpdateWidget(_NameField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_focus.hasFocus) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  List<String> get options => widget.options;
  String? get value => widget.value;
  bool get enabled => widget.enabled;

  List<_Option> _optionsFor(String text) {
    final typed = normaliseName(text);
    final key = typed.toLowerCase();
    final matches = [
      for (final o in options)
        if (key.isEmpty || o.toLowerCase().contains(key)) _Option(o),
    ];
    final exact = options.any((o) => o.toLowerCase() == key);
    return [
      ...matches,
      if (typed.isNotEmpty && !exact && typed.length <= maxCategoryNameLength)
        _Option(typed, create: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final narrow = MediaQuery.sizeOf(context).width < WpBreakpoints.medium;
    return RawAutocomplete<_Option>(
      focusNode: _focus,
      textEditingController: _controller,
      optionsViewOpenDirection: narrow
          ? OptionsViewOpenDirection.up
          : OptionsViewOpenDirection.down,
      optionsBuilder: (v) => enabled ? _optionsFor(v.text) : const [],
      displayStringForOption: (o) => o.name,
      onSelected: (o) {
        _focus.unfocus();
        widget.onChosen(o.name);
      },
      fieldViewBuilder: (context, controller, focus, onSubmitted) {
        return TextField(
          key: widget.fieldKey,
          controller: controller,
          focusNode: focus,
          enabled: enabled,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: widget.label,
            suffixIcon: value == null || !enabled
                ? null
                : IconButton(
                    tooltip: widget.clearTooltip,
                    icon: const Icon(Symbols.close_rounded),
                    onPressed: widget.onCleared,
                  ),
          ),
          onSubmitted: (text) {
            final name = normaliseName(text);
            if (name.isEmpty) {
              if (value != null) widget.onCleared();
              return;
            }
            // Enter picks an existing name (any case) or creates the typed one.
            final existing = options.where(
              (o) => o.toLowerCase() == name.toLowerCase(),
            );
            widget.onChosen(existing.isEmpty ? name : existing.first);
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: narrow ? Alignment.bottomLeft : Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(WpRadius.field),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 360),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final o in options)
                    ListTile(
                      leading: Icon(
                        o.create ? Symbols.add_rounded : Symbols.label_rounded,
                      ),
                      title: Text(
                        o.create ? l10n.categoryCreate(o.name) : o.name,
                      ),
                      onTap: () => onSelected(o),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
