import 'package:drift/drift.dart';

import '../db/database.dart';

/// Categories are shared across wordlists; a row with `parentId` is a
/// subcategory.
class CategoryRepo {
  CategoryRepo(this._db);

  final AppDatabase _db;

  /// All categories and subcategories, by name.
  Stream<List<Category>> watchAll() => (_db.select(
    _db.categories,
  )..orderBy([(c) => OrderingTerm.asc(c.key)])).watch();

  Future<List<Category>> all() => (_db.select(
    _db.categories,
  )..orderBy([(c) => OrderingTerm.asc(c.key)])).get();

  Future<Category?> get(String id) => (_db.select(
    _db.categories,
  )..where((c) => c.id.equals(id))).getSingleOrNull();

  /// The category with [key] at one level (top level when [parentId] is null).
  Future<Category?> byKey(String key, {String? parentId}) =>
      (_db.select(_db.categories)..where(
            (c) =>
                c.key.equals(key) &
                (parentId == null
                    ? c.parentId.isNull()
                    : c.parentId.equals(parentId)),
          ))
          .getSingleOrNull();

  Future<void> insert(CategoriesCompanion row) =>
      _db.into(_db.categories).insert(row);
}
