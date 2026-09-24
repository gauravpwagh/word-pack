import 'package:drift/drift.dart';

import '../data/db/database.dart';
import '../data/repositories/category_repo.dart';
import '../data/repositories/pack_repo.dart';
import '../data/repositories/settings_repo.dart';
import '../domain/categories.dart';
import '../domain/clock.dart';
import '../domain/ids.dart';
import '../domain/learning.dart';
import '../domain/models.dart';
import 'exceptions.dart';

/// Tone, traits, category and subcategory of a word — only for words whose
/// pack is Learned (D-9, `docs/REQUIREMENTS.md` CAT-1 … CAT-6, TAG-1 … TAG-2).
/// Each method is one transaction.
class TaggingService {
  TaggingService({
    required AppDatabase db,
    required Clock clock,
    required IdGenerator ids,
  }) : _db = db,
       _clock = clock,
       _ids = ids,
       _packs = PackRepo(db),
       _categories = CategoryRepo(db),
       _settings = SettingsRepo(db);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;
  final PackRepo _packs;
  final CategoryRepo _categories;
  final SettingsRepo _settings;

  /// Sets the tone, or clears it with null. Traits are untouched.
  Future<void> setTone(String wordId, Tone? tone) => _db.transaction(() async {
    await _learnedWord(wordId);
    await _write(wordId, WordsCompanion(tone: Value(tone)));
  });

  /// Turns a trait on or off.
  Future<void> toggleTrait(String wordId, Trait trait) =>
      _db.transaction(() async {
        final word = await _learnedWord(wordId);
        await _write(
          wordId,
          trait == Trait.counterIntuitive
              ? WordsCompanion(counterIntuitive: Value(!word.counterIntuitive))
              : WordsCompanion(multipleMeanings: Value(!word.multipleMeanings)),
        );
      });

  /// Assigns a category and optional subcategory by name, creating either if
  /// it does not exist yet (matching is case-insensitive; the first spelling
  /// entered is kept). A null [category] clears both (CAT-5).
  Future<void> assign(
    String wordId, {
    required String? category,
    String? subcategory,
  }) => _db.transaction(() async {
    await _learnedWord(wordId);
    if (category == null || normaliseName(category).isEmpty) {
      if (subcategory != null && normaliseName(subcategory).isNotEmpty) {
        throw const InvalidSubcategoryException(
          'subcategory without a category',
        );
      }
      await _write(
        wordId,
        const WordsCompanion(
          categoryId: Value(null),
          subcategoryId: Value(null),
        ),
      );
      return;
    }
    final cat = await _findOrCreate(category, parentId: null);
    final sub = subcategory == null || normaliseName(subcategory).isEmpty
        ? null
        : await _findOrCreate(subcategory, parentId: cat.id);
    await _write(
      wordId,
      WordsCompanion(categoryId: Value(cat.id), subcategoryId: Value(sub?.id)),
    );
  });

  /// Assigns existing categories by id; the subcategory must be under the
  /// category (DATA_MODEL invariant 3).
  Future<void> setCategoryIds(
    String wordId, {
    required String? categoryId,
    String? subcategoryId,
  }) => _db.transaction(() async {
    await _learnedWord(wordId);
    final sub = subcategoryId == null
        ? null
        : await _categories.get(subcategoryId);
    if (subcategoryId != null && sub == null) {
      throw InvalidSubcategoryException('unknown subcategory $subcategoryId');
    }
    checkAssignment(
      categoryId: categoryId,
      subcategory: sub == null
          ? null
          : CategoryRef(id: sub.id, name: sub.name, parentId: sub.parentId),
    );
    if (categoryId != null) {
      final cat = await _categories.get(categoryId);
      if (cat == null || cat.parentId != null) {
        throw InvalidSubcategoryException('unknown category $categoryId');
      }
    }
    await _write(
      wordId,
      WordsCompanion(
        categoryId: Value(categoryId),
        subcategoryId: Value(subcategoryId),
      ),
    );
  });

  // -------------------------------------------------------------------------

  Future<Word> _learnedWord(String wordId) async {
    final word = await (_db.select(
      _db.words,
    )..where((w) => w.id.equals(wordId))).getSingleOrNull();
    if (word == null) throw WordNotFoundException(wordId);
    final pack = (await _packs.get(word.packId))!;
    final rule = (await _settings.get()).learnedRule;
    if (!isLearned(pack.masteryWd, pack.masteryDw, rule)) {
      throw WordNotLearnedException(wordId);
    }
    return word;
  }

  Future<void> _write(String wordId, WordsCompanion changes) =>
      (_db.update(_db.words)..where((w) => w.id.equals(wordId))).write(
        changes.copyWith(updatedAt: Value(_clock.now())),
      );

  Future<Category> _findOrCreate(
    String name, {
    required String? parentId,
  }) async {
    final display = validateCategoryName(name);
    final key = categoryKey(display);
    final existing = await _categories.byKey(key, parentId: parentId);
    if (existing != null) return existing;
    final id = _ids.newId();
    await _categories.insert(
      CategoriesCompanion.insert(
        id: id,
        name: display,
        key: key,
        parentId: Value(parentId),
        createdAt: _clock.now(),
      ),
    );
    return (await _categories.get(id))!;
  }
}
