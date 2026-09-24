import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/data/repositories/category_repo.dart';
import 'package:wordpack/data/repositories/pack_repo.dart';
import 'package:wordpack/data/repositories/word_repo.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/services/exceptions.dart';
import 'package:wordpack/services/import_service.dart';
import 'package:wordpack/services/tagging_service.dart';

import '../support/test_db.dart';

void main() {
  late AppDatabase db;
  late TaggingService tags;
  late List<Word> pack1;
  late List<Word> pack2;

  Future<Word> reload(Word w) async => (await (db.select(
    db.words,
  )..where((x) => x.id.equals(w.id))).get()).single;

  setUp(() async {
    db = memoryDb();
    final importer = ImportService(db: db, clock: FixedClock(), ids: SeqIds());
    final report = await importer.preview(
      File('fixtures/sample-columns.csv').readAsBytesSync(),
    );
    final listId = await importer.commit(
      report,
      name: '',
      sourceFilename: 'x.csv',
    );
    final packs = await PackRepo(db).forWordlist(listId);
    // Pack 1 is Learned (both directions mastered), pack 2 is not.
    await (db.update(db.packs)..where((p) => p.id.equals(packs[0].id))).write(
      const PacksCompanion(
        masteryWd: Value(Mastery.mastered),
        masteryDw: Value(Mastery.mastered),
      ),
    );
    pack1 = await WordRepo(db).forPack(packs[0].id);
    pack2 = await WordRepo(db).forPack(packs[1].id);
    tags = TaggingService(db: db, clock: FixedClock(), ids: _Ids());
  });
  tearDown(() => db.close());

  group('R-7 learned-only rule', () {
    test('a word of a pack that is not Learned is rejected', () async {
      final w = pack2.first;
      for (final action in [
        () => tags.setTone(w.id, Tone.positive),
        () => tags.toggleTrait(w.id, Trait.counterIntuitive),
        () => tags.assign(w.id, category: 'Law'),
        () => tags.setCategoryIds(w.id, categoryId: null),
      ]) {
        await expectLater(action(), throwsA(isA<WordNotLearnedException>()));
      }
      expect((await reload(w)).tone, isNull);
      expect(await CategoryRepo(db).all(), isEmpty);
    });

    test('a word of a Learned pack is saved', () async {
      final w = pack1.first;
      await tags.setTone(w.id, Tone.negative);
      await tags.toggleTrait(w.id, Trait.counterIntuitive);
      var saved = await reload(w);
      expect(saved.tone, Tone.negative);
      expect(saved.counterIntuitive, isTrue);
      expect(saved.multipleMeanings, isFalse);

      // Tone replaced, then cleared; traits toggle independently.
      await tags.setTone(w.id, Tone.positive);
      await tags.toggleTrait(w.id, Trait.multipleMeanings);
      await tags.toggleTrait(w.id, Trait.counterIntuitive);
      await tags.setTone(w.id, null);
      saved = await reload(w);
      expect(saved.tone, isNull);
      expect(saved.counterIntuitive, isFalse);
      expect(saved.multipleMeanings, isTrue);
    });

    test('the learned rule setting decides', () async {
      await (db.update(db.packs)..where((p) => p.id.equals(pack2.first.packId)))
          .write(const PacksCompanion(masteryWd: Value(Mastery.mastered)));
      await expectLater(
        tags.setTone(pack2.first.id, Tone.neutral),
        throwsA(isA<WordNotLearnedException>()),
      );
      await db
          .update(db.appSettings)
          .write(
            const AppSettingsCompanion(learnedRule: Value(LearnedRule.either)),
          );
      await tags.setTone(pack2.first.id, Tone.neutral);
      expect((await reload(pack2.first)).tone, Tone.neutral);
    });

    test('unknown word', () async {
      await expectLater(
        tags.setTone('nope', Tone.positive),
        throwsA(isA<WordNotFoundException>()),
      );
    });
  });

  group('R-8 categories: find-or-create, case-insensitive', () {
    test("assign(word, 'Emotions', 'Anger') creates both once", () async {
      await tags.assign(
        pack1[0].id,
        category: 'Emotions',
        subcategory: 'Anger',
      );
      await tags.assign(
        pack1[1].id,
        category: '  emotions ',
        subcategory: 'ANGER',
      );
      final all = await CategoryRepo(db).all();
      expect(all, hasLength(2));
      final emotions = all.firstWhere((c) => c.parentId == null);
      final anger = all.firstWhere((c) => c.parentId != null);
      expect(emotions.name, 'Emotions');
      expect(anger.name, 'Anger');
      expect(anger.parentId, emotions.id);

      for (final w in [pack1[0], pack1[1]]) {
        final saved = await reload(w);
        expect(saved.categoryId, emotions.id);
        expect(saved.subcategoryId, anger.id);
      }
    });

    test('same subcategory name under two categories', () async {
      await tags.assign(
        pack1[0].id,
        category: 'Emotions',
        subcategory: 'Places',
      );
      await tags.assign(
        pack1[1].id,
        category: 'Religion',
        subcategory: 'Places',
      );
      final subs = (await CategoryRepo(
        db,
      ).all()).where((c) => c.parentId != null);
      expect(subs, hasLength(2));
    });

    test('clearing the category clears the subcategory', () async {
      await tags.assign(pack1[0].id, category: 'Law', subcategory: 'Courts');
      await tags.assign(pack1[0].id, category: null);
      final saved = await reload(pack1[0]);
      expect(saved.categoryId, isNull);
      expect(saved.subcategoryId, isNull);
      await tags.assign(pack1[0].id, category: 'Law', subcategory: ' ');
      expect((await reload(pack1[0])).subcategoryId, isNull);
    });

    test('subcategory without category or with the wrong parent', () async {
      await expectLater(
        tags.assign(pack1[0].id, category: ' ', subcategory: 'Anger'),
        throwsA(isA<InvalidSubcategoryException>()),
      );
      await tags.assign(
        pack1[0].id,
        category: 'Emotions',
        subcategory: 'Anger',
      );
      await tags.assign(pack1[1].id, category: 'Law');
      final all = await CategoryRepo(db).all();
      final law = all.firstWhere((c) => c.name == 'Law');
      final anger = all.firstWhere((c) => c.name == 'Anger');
      await expectLater(
        tags.setCategoryIds(
          pack1[1].id,
          categoryId: law.id,
          subcategoryId: anger.id,
        ),
        throwsA(isA<InvalidSubcategoryException>()),
      );
      await expectLater(
        tags.setCategoryIds(
          pack1[1].id,
          categoryId: null,
          subcategoryId: anger.id,
        ),
        throwsA(isA<InvalidSubcategoryException>()),
      );
      await expectLater(
        tags.setCategoryIds(pack1[1].id, categoryId: anger.id),
        throwsA(isA<InvalidSubcategoryException>()),
      );
      await expectLater(
        tags.setCategoryIds(
          pack1[1].id,
          categoryId: law.id,
          subcategoryId: 'x',
        ),
        throwsA(isA<InvalidSubcategoryException>()),
      );
      await tags.setCategoryIds(
        pack1[1].id,
        categoryId: anger.parentId,
        subcategoryId: anger.id,
      );
      expect((await reload(pack1[1])).subcategoryId, anger.id);
    });

    test('names must be 1–80 characters', () async {
      await expectLater(
        tags.assign(pack1[0].id, category: 'x' * 81),
        throwsA(isA<InvalidCategoryNameException>()),
      );
    });
  });
}

class _Ids extends SeqIds {
  @override
  String newId() => 't-${super.newId()}';
}
