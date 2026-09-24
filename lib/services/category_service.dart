import 'package:drift/drift.dart';

import '../data/db/database.dart';
import '../domain/categories.dart';

/// Another category already has this name at that level (use merge instead).
class CategoryNameTakenException implements Exception {
  const CategoryNameTakenException(this.existingId);

  final String existingId;

  @override
  String toString() => 'CategoryNameTakenException($existingId)';
}

class CategoryNotFoundException implements Exception {
  const CategoryNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'CategoryNotFoundException($id)';
}

/// Merging across levels, or a category into itself.
class InvalidMergeException implements Exception {
  const InvalidMergeException(this.message);

  final String message;

  @override
  String toString() => 'InvalidMergeException: $message';
}

/// A category or subcategory with the number of words using it.
class CategoryUsage {
  const CategoryUsage({required this.category, required this.words});

  final Category category;
  final int words;
}

/// Manage categories: rename, merge, delete (CAT-7, `docs/DATA_MODEL.md` §5).
/// Each method is one transaction; words keep their tone and trait tags.
class CategoryService {
  CategoryService(this._db);

  final AppDatabase _db;

  /// Every category and subcategory with its word count, updated live.
  Stream<List<CategoryUsage>> watchUsage() => _db
      .customSelect(
        '''
        SELECT c.*, (SELECT COUNT(*) FROM words w
          WHERE w.category_id = c.id OR w.subcategory_id = c.id) AS n
        FROM categories c ORDER BY c.key
        ''',
        readsFrom: {_db.categories, _db.words},
      )
      .watch()
      .asyncMap(
        (rows) async => [
          for (final r in rows)
            CategoryUsage(
              category: await _db.categories.mapFromRow(r),
              words: r.read<int>('n'),
            ),
        ],
      );

  Future<Category> _get(String id) async {
    final c = await (_db.select(
      _db.categories,
    )..where((x) => x.id.equals(id))).getSingleOrNull();
    if (c == null) throw CategoryNotFoundException(id);
    return c;
  }

  Future<Category?> _sameLevel(String key, String? parentId) =>
      (_db.select(_db.categories)..where(
            (c) =>
                c.key.equals(key) &
                (parentId == null
                    ? c.parentId.isNull()
                    : c.parentId.equals(parentId)),
          ))
          .getSingleOrNull();

  /// Renames; changing only the case is allowed. Throws
  /// [CategoryNameTakenException] when another category at the same level
  /// already uses the name.
  Future<void> rename(String id, String name) => _db.transaction(() async {
    final c = await _get(id);
    final display = validateCategoryName(name);
    final key = categoryKey(display);
    final clash = await _sameLevel(key, c.parentId);
    if (clash != null && clash.id != id) {
      throw CategoryNameTakenException(clash.id);
    }
    await (_db.update(_db.categories)..where((x) => x.id.equals(id))).write(
      CategoriesCompanion(name: Value(display), key: Value(key)),
    );
  });

  /// Moves everything from [sourceId] into [targetId] (same level) and
  /// deletes the source. Merging categories also merges their subcategories
  /// by name; the rest move across.
  Future<void> merge(String sourceId, String targetId) => _db.transaction(
    () async {
      if (sourceId == targetId) {
        throw const InvalidMergeException('same category');
      }
      final a = await _get(sourceId);
      final b = await _get(targetId);
      if ((a.parentId == null) != (b.parentId == null)) {
        throw const InvalidMergeException('different levels');
      }

      if (a.parentId != null) {
        // Subcategories: words follow; if the parents differ the word's
        // category follows too.
        await (_db.update(
          _db.words,
        )..where((w) => w.subcategoryId.equals(a.id))).write(
          WordsCompanion(
            subcategoryId: Value(b.id),
            categoryId: Value(b.parentId),
          ),
        );
      } else {
        final subsA = await (_db.select(
          _db.categories,
        )..where((c) => c.parentId.equals(a.id))).get();
        for (final s in subsA) {
          final twin = await _sameLevel(s.key, b.id);
          if (twin == null) {
            await (_db.update(_db.categories)..where((c) => c.id.equals(s.id)))
                .write(CategoriesCompanion(parentId: Value(b.id)));
          } else {
            await (_db.update(_db.words)
                  ..where((w) => w.subcategoryId.equals(s.id)))
                .write(WordsCompanion(subcategoryId: Value(twin.id)));
            await (_db.delete(
              _db.categories,
            )..where((c) => c.id.equals(s.id))).go();
          }
        }
        await (_db.update(_db.words)..where((w) => w.categoryId.equals(a.id)))
            .write(WordsCompanion(categoryId: Value(b.id)));
      }
      await (_db.delete(_db.categories)..where((c) => c.id.equals(a.id))).go();
    },
  );

  /// Deletes a category (its subcategories go with it) or a subcategory.
  /// Affected words lose the category/subcategory (foreign keys set null).
  Future<void> delete(String id) => _db.transaction(() async {
    await _get(id);
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  });
}
