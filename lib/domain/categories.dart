/// Category and subcategory names and rules (`docs/REQUIREMENTS.md` CAT-2 …
/// CAT-6, `docs/DATA_MODEL.md` §3). Categories are shared across wordlists and
/// at most two levels deep.
library;

const int maxCategoryNameLength = 80;

final _whitespace = RegExp(r'\s+');

/// Trimmed, inner whitespace collapsed: the spelling that is stored.
String normaliseName(String name) => name.trim().split(_whitespace).join(' ');

/// Case-insensitive matching key.
String categoryKey(String name) => normaliseName(name).toLowerCase();

/// Name is empty or too long after normalising.
class InvalidCategoryNameException implements Exception {
  const InvalidCategoryNameException(this.name);

  final String name;

  @override
  String toString() => 'InvalidCategoryNameException("$name")';
}

/// A subcategory without a category, or under a different category.
class InvalidSubcategoryException implements Exception {
  const InvalidSubcategoryException(this.message);

  final String message;

  @override
  String toString() => 'InvalidSubcategoryException: $message';
}

/// Normalised display name, or [InvalidCategoryNameException].
String validateCategoryName(String name) {
  final n = normaliseName(name);
  if (n.isEmpty || n.length > maxCategoryNameLength) {
    throw InvalidCategoryNameException(name);
  }
  return n;
}

/// A stored category (top level when [parentId] is null).
final class CategoryRef {
  const CategoryRef({
    required this.id,
    required this.name,
    required this.parentId,
  });

  final String id;

  /// Display spelling: the first one entered.
  final String name;
  final String? parentId;

  String get key => categoryKey(name);
}

/// The category matching [name] (case-insensitively) at one level: top level
/// when [parentId] is null, else among that category's subcategories.
CategoryRef? findCategory(
  Iterable<CategoryRef> categories,
  String name, {
  String? parentId,
}) {
  final key = categoryKey(name);
  for (final c in categories) {
    if (c.parentId == parentId && c.key == key) return c;
  }
  return null;
}

/// Checks a word's category assignment (DATA_MODEL invariant 3):
/// a subcategory needs a category, and must belong to it.
void checkAssignment({
  required String? categoryId,
  required CategoryRef? subcategory,
}) {
  if (subcategory == null) return;
  if (categoryId == null) {
    throw const InvalidSubcategoryException('subcategory without a category');
  }
  if (subcategory.parentId != categoryId) {
    throw InvalidSubcategoryException(
      '"${subcategory.name}" is not under the chosen category',
    );
  }
}
