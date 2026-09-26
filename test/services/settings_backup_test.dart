import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/data/repositories/pack_repo.dart';
import 'package:wordpack/data/repositories/word_repo.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/services/backup_service.dart';
import 'package:wordpack/services/category_service.dart';
import 'package:wordpack/services/import_service.dart';
import 'package:wordpack/services/learning_service.dart';
import 'package:wordpack/services/settings_service.dart';
import 'package:wordpack/services/tagging_service.dart';

import '../support/test_db.dart';

class _Ids extends SeqIds {
  _Ids(this.prefix);

  final String prefix;

  @override
  String newId() => '$prefix-${super.newId()}';
}

void main() {
  late AppDatabase db;
  late String wl;
  late SettingsService settings;
  final clock = FixedClock();

  Future<List<Word>> words() => WordRepo(db).forWordlist(wl);

  /// Marks words [from, to) mastered in the given directions.
  Future<void> master(int from, int to, {required bool wd, required bool dw}) =>
      (db.update(db.words)..where(
            (w) =>
                w.wordlistId.equals(wl) &
                w.position.isBiggerOrEqualValue(from) &
                w.position.isSmallerThanValue(to),
          ))
          .write(WordsCompanion(masteredWd: Value(wd), masteredDw: Value(dw)));

  /// Pack 1 counts as Learned (both directions mastered).
  Future<void> learnPack1() =>
      (db.update(db.packs)..where((p) => p.number.equals(1))).write(
        const PacksCompanion(
          masteryWd: Value(Mastery.mastered),
          masteryDw: Value(Mastery.mastered),
        ),
      );

  setUp(() async {
    db = memoryDb();
    final importer = ImportService(db: db, clock: clock, ids: _Ids('i'));
    final report = await importer.preview(
      File('fixtures/definitions.txt').readAsBytesSync(),
    );
    wl = await importer.commit(report, name: '', sourceFilename: 'd.txt');
    settings = SettingsService(db: db, clock: clock, ids: _Ids('s'));
  });
  tearDown(() => db.close());

  group('R-9 pack-size change', () {
    test('preview counts packs and open passes', () async {
      await LearningService(
        db: db,
        clock: clock,
        ids: _Ids('l'),
      ).open((await PackRepo(db).forWordlist(wl)).first.id, Direction.wd);
      final p = await settings.previewPackSizeChange(20);
      expect(p.size, 20);
      expect(p.wordlists.single, (name: 'd', before: 34, after: 50));
      expect(p.openPasses, 1);
    });

    test('rebuild to 20 matches U-12; passes discarded; tags kept', () async {
      // Old pack 1 (0–29) learned WD+DW, old pack 2 (30–59) WD only.
      await master(0, 30, wd: true, dw: true);
      await master(30, 60, wd: true, dw: false);
      final firstId = (await words()).first.id;
      await (db.update(db.words)..where((w) => w.id.equals(firstId))).write(
        const WordsCompanion(tone: Value(Tone.positive)),
      );
      await LearningService(
        db: db,
        clock: clock,
        ids: _Ids('l'),
      ).open((await PackRepo(db).forWordlist(wl))[5].id, Direction.dw);

      await settings.applyPackSizeChange(20);

      final packs = await PackRepo(db).forWordlist(wl);
      expect(packs, hasLength(50));
      expect(
        [for (final p in packs) p.number],
        [for (var i = 1; i <= 50; i++) i],
      );
      PackStatus status(int i) =>
          packs[i].let((p) => (p.masteryWd, p.masteryDw)).toStatus();
      expect(status(0), PackStatus.learned);
      expect(packs[0].learnedAt, clock.at);
      expect(
        (packs[1].masteryWd, packs[1].masteryDw),
        (Mastery.mastered, Mastery.learning),
      );
      expect(
        (packs[2].masteryWd, packs[2].masteryDw),
        (Mastery.mastered, Mastery.unseen),
      );
      expect(status(3), PackStatus.newPack);

      // Every word in exactly one pack, consecutive, ≤ 20.
      final all = await words();
      for (final p in packs) {
        final inPack = all.where((w) => w.packId == p.id).toList();
        expect(inPack.length, inInclusiveRange(1, 20));
        expect(inPack.first.position, (p.number - 1) * 20);
      }
      expect(await db.select(db.passSessions).get(), isEmpty);
      expect((await db.select(db.appSettings).getSingle()).packSize, 20);
      expect(all.first.tone, Tone.positive);
    });

    test('sizes outside 5–100 are rejected', () async {
      for (final n in [4, 101]) {
        await expectLater(
          settings.applyPackSizeChange(n),
          throwsA(isA<InvalidPackSizeException>()),
        );
        await expectLater(
          settings.previewPackSizeChange(n),
          throwsA(isA<InvalidPackSizeException>()),
        );
      }
      expect(await PackRepo(db).forWordlist(wl), hasLength(34));
    });
  });

  test(
    'R-10 changing the learned rule changes statuses, writes nothing',
    () async {
      await (db.update(db.packs)..where((p) => p.number.equals(1))).write(
        const PacksCompanion(masteryWd: Value(Mastery.mastered)),
      );
      Future<PackStatus> pack1() async {
        final rule = (await db.select(db.appSettings).getSingle()).learnedRule;
        return (await PackRepo(db).watchRows(wl).first).first.status(rule);
      }

      final packsBefore = await db.select(db.packs).get();
      expect(await pack1(), PackStatus.learning);
      await settings.setLearnedRule(LearnedRule.either);
      expect(await pack1(), PackStatus.learned);
      await settings.setLearnedRule(LearnedRule.dwOnly);
      expect(await pack1(), PackStatus.learning);
      expect(await db.select(db.packs).get(), packsBefore);
    },
  );

  test('simple settings', () async {
    await settings.setDefaultDirection(Direction.dw);
    await settings.setShowPos(false);
    await settings.setDemoteOnReveal(true);
    await settings.setTheme('dark');
    final s = await db.select(db.appSettings).getSingle();
    expect(s.defaultDirection, Direction.dw);
    expect(s.showPos, isFalse);
    expect(s.demoteOnReveal, isTrue);
    expect(s.theme, 'dark');
    expect(() => settings.setTheme('pink'), throwsArgumentError);
  });

  group('R-12 backup', () {
    test('export → restore into an empty database → identical data', () async {
      await master(0, 30, wd: true, dw: true);
      await learnPack1();
      final tags = TaggingService(db: db, clock: clock, ids: _Ids('t'));
      final first = (await words()).first;
      await tags.assign(first.id, category: 'Religion', subcategory: 'Places');
      await tags.setTone(first.id, Tone.negative);
      await LearningService(
        db: db,
        clock: clock,
        ids: _Ids('l'),
      ).open((await PackRepo(db).forWordlist(wl))[2].id, Direction.dw);
      await settings.setDefaultDirection(Direction.dw);

      final backup = BackupService(db: db, clock: clock);
      final json = await backup.export();
      expect(backup.fileName(), 'wordpack-backup-2026-09-24.json');
      final info = backup.inspect(json);
      expect(info.wordlists, 1);
      expect(info.words, 998);
      expect(info.exportedAt, clock.at);

      final other = memoryDb();
      addTearDown(other.close);
      await BackupService(db: other, clock: clock).restore(json);

      // Compared as JSON: generated == compares list fields by identity.
      Future<String> dump(AppDatabase d) async => jsonEncode([
        for (final rows in [
          await d.select(d.wordlists).get(),
          await d.select(d.packs).get(),
          await d.select(d.words).get(),
          await d.select(d.categories).get(),
          await d.select(d.passSessions).get(),
          await d.select(d.appSettings).get(),
        ])
          [for (final r in rows) r.toJson()],
      ]);
      expect(await dump(other), await dump(db));
    });

    test('restore replaces what was there', () async {
      final json = await BackupService(db: db, clock: clock).export();
      final other = memoryDb();
      addTearDown(other.close);
      final importer = ImportService(db: other, clock: clock, ids: _Ids('o'));
      final r = await importer.preview(
        File('fixtures/edge-cases.txt').readAsBytesSync(),
      );
      await importer.commit(r, name: 'old', sourceFilename: 'e.txt');
      await BackupService(db: other, clock: clock).restore(json);
      final lists = await other.select(other.wordlists).get();
      expect([for (final l in lists) l.name], ['d']);
    });

    test('D-34 a backup without studyButtons restores it as on', () async {
      await settings.setStudyButtons(false);
      final data =
          jsonDecode(await BackupService(db: db, clock: clock).export())
              as Map<String, dynamic>;
      expect((data['settings'] as Map)['studyButtons'], isFalse);
      (data['settings'] as Map).remove('studyButtons');
      final other = memoryDb();
      addTearDown(other.close);
      await (other.update(
        other.appSettings,
      )).write(const AppSettingsCompanion(studyButtons: Value(false)));
      await BackupService(db: other, clock: clock).restore(jsonEncode(data));
      expect(
        (await other.select(other.appSettings).getSingle()).studyButtons,
        isTrue,
      );
    });

    test('invalid files are rejected and change nothing', () async {
      final backup = BackupService(db: db, clock: clock);
      final good = jsonDecode(await backup.export()) as Map<String, dynamic>;
      for (final bad in [
        'not json',
        '[]',
        jsonEncode({...good, 'app': 'other'}),
        jsonEncode({...good, 'schemaVersion': 2}),
        jsonEncode({...good, 'words': 'nope'}),
        jsonEncode({
          ...good,
          'words': [
            {'id': 5},
          ],
        }),
      ]) {
        await expectLater(
          backup.restore(bad),
          throwsA(isA<BackupFormatException>()),
          reason: bad.length > 40 ? bad.substring(0, 40) : bad,
        );
      }
      expect(await WordRepo(db).countAll(), 998);
    });
  });

  group('categories: rename, merge, delete', () {
    late TaggingService tags;
    late CategoryService cats;
    late List<Word> ws;

    Future<Category> named(String name) async =>
        (await db.select(db.categories).get()).firstWhere(
          (c) => c.name == name,
        );

    setUp(() async {
      await master(0, 30, wd: true, dw: true);
      await learnPack1();
      tags = TaggingService(db: db, clock: clock, ids: _Ids('t'));
      cats = CategoryService(db);
      ws = await words();
      await tags.assign(ws[0].id, category: 'Emotions', subcategory: 'Anger');
      await tags.assign(ws[1].id, category: 'Emotions', subcategory: 'Joy');
      await tags.assign(ws[2].id, category: 'Feelings', subcategory: 'Anger');
      await tags.assign(ws[3].id, category: 'Feelings', subcategory: 'Fear');
      await tags.assign(ws[4].id, category: 'Feelings');
      await tags.setTone(ws[4].id, Tone.neutral);
    });

    test('usage counts', () async {
      final usage = await cats.watchUsage().first;
      int count(String name) =>
          usage.firstWhere((u) => u.category.name == name).words;
      expect(count('Emotions'), 2);
      expect(count('Feelings'), 3);
      expect(usage.where((u) => u.category.name == 'Anger'), hasLength(2));
    });

    test('rename, including a case-only change; clashes are refused', () async {
      final emotions = await named('Emotions');
      await cats.rename(emotions.id, 'Moods');
      await cats.rename(emotions.id, 'MOODS');
      expect((await named('MOODS')).key, 'moods');
      await expectLater(
        cats.rename(emotions.id, 'feelings'),
        throwsA(isA<CategoryNameTakenException>()),
      );
      await expectLater(
        cats.rename('nope', 'x'),
        throwsA(isA<CategoryNotFoundException>()),
      );
    });

    test('merge categories merges subcategories by name', () async {
      final feelings = await named('Feelings');
      final emotions = await named('Emotions');
      await cats.merge(feelings.id, emotions.id);

      final all = await db.select(db.categories).get();
      expect(all.where((c) => c.name == 'Feelings'), isEmpty);
      final subs = {
        for (final c in all.where((c) => c.parentId == emotions.id)) c.name,
      };
      expect(subs, {'Anger', 'Joy', 'Fear'});
      final after = await words();
      expect(after.take(5).every((w) => w.categoryId == emotions.id), isTrue);
      expect(after[2].subcategoryId, after[0].subcategoryId, reason: 'Anger');
      expect(after[4].subcategoryId, isNull);
      expect(after[4].tone, Tone.neutral, reason: 'tags stay');
    });

    test('merge subcategories, across parents', () async {
      final joy = (await db.select(db.categories).get()).firstWhere(
        (c) => c.name == 'Joy',
      );
      final fear = (await db.select(db.categories).get()).firstWhere(
        (c) => c.name == 'Fear',
      );
      await cats.merge(joy.id, fear.id);
      final w1 = (await words())[1];
      expect(w1.subcategoryId, fear.id);
      expect(w1.categoryId, fear.parentId);
      await expectLater(
        cats.merge(fear.id, fear.id),
        throwsA(isA<InvalidMergeException>()),
      );
      await expectLater(
        cats.merge(fear.id, fear.parentId!),
        throwsA(isA<InvalidMergeException>()),
      );
    });

    test('delete a category: subcategories go, words uncategorised', () async {
      final feelings = await named('Feelings');
      await cats.delete(feelings.id);
      final all = await db.select(db.categories).get();
      expect(all.where((c) => c.parentId == feelings.id), isEmpty);
      final after = await words();
      for (final w in after.skip(2).take(3)) {
        expect(w.categoryId, isNull);
        expect(w.subcategoryId, isNull);
      }
      expect(after[4].tone, Tone.neutral);
      expect(after[0].categoryId, isNotNull);
    });

    test('delete a subcategory keeps the category', () async {
      final joy = (await db.select(db.categories).get()).firstWhere(
        (c) => c.name == 'Joy',
      );
      await cats.delete(joy.id);
      final w1 = (await words())[1];
      expect(w1.subcategoryId, isNull);
      expect(w1.categoryId, joy.parentId);
      await expectLater(
        cats.delete(joy.id),
        throwsA(isA<CategoryNotFoundException>()),
      );
    });
  });
}

extension<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

extension on (Mastery, Mastery) {
  PackStatus toStatus() => ($1 == Mastery.mastered && $2 == Mastery.mastered)
      ? PackStatus.learned
      : ($1 == Mastery.unseen && $2 == Mastery.unseen)
      ? PackStatus.newPack
      : PackStatus.learning;
}
