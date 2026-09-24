import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/data/repositories/pack_repo.dart';
import 'package:wordpack/data/repositories/pass_repo.dart';
import 'package:wordpack/data/repositories/settings_repo.dart';
import 'package:wordpack/data/repositories/word_repo.dart';
import 'package:wordpack/data/repositories/wordlist_repo.dart';
import 'package:wordpack/domain/learning.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/services/exceptions.dart';
import 'package:wordpack/services/import_service.dart';
import 'package:wordpack/services/wordlist_service.dart';

import '../support/test_db.dart';

Uint8List fixture(String name) => File('fixtures/$name').readAsBytesSync();

/// Expected results from fixtures/README.md: words, skipped, duplicates,
/// packs at size 30, last pack size.
const expectations = {
  'definitions.txt': (998, 0, 0, 34, 8),
  'sample-excel-dash.csv': (60, 0, 0, 2, 30),
  'sample-columns.csv': (60, 0, 0, 2, 30),
  'edge-cases.txt': (9, 1, 1, 1, 9),
};

void main() {
  late AppDatabase db;
  late ImportService service;

  setUp(() {
    db = memoryDb();
    service = ImportService(db: db, clock: FixedClock(), ids: SeqIds());
  });
  tearDown(() => db.close());

  Future<String> importFixture(String name) async {
    final report = await service.preview(fixture(name));
    return service.commit(report, name: '', sourceFilename: name);
  }

  group('R-1 commit each fixture', () {
    for (final MapEntry(key: file, value: e) in expectations.entries) {
      test(file, () async {
        final (words, skipped, dups, packs, lastPack) = e;
        final report = await service.preview(fixture(file));
        expect(report.words, hasLength(words));
        expect(report.skipped, hasLength(skipped));
        expect(report.duplicatesRemoved, dups);

        final id = await service.commit(report, name: '', sourceFilename: file);
        final list = (await WordlistRepo(db).get(id))!;
        expect(list.name, file.substring(0, file.lastIndexOf('.')));
        expect(list.wordCount, words);
        expect(list.sourceFormat, report.format.name);

        final rows = await PackRepo(db).watchRows(id).first;
        expect(rows, hasLength(packs));
        expect(rows.last.wordCount, lastPack);
        expect(
          [for (final r in rows) r.pack.number],
          [for (var i = 1; i <= packs; i++) i],
        );
        expect(
          rows.every((r) => r.status(LearnedRule.both) == PackStatus.newPack),
          isTrue,
        );

        final stored = await WordRepo(db).forWordlist(id);
        expect(
          [for (final w in stored) w.position],
          [for (var i = 0; i < words; i++) i],
        );
        expect(
          [for (final w in stored) w.term],
          [for (final w in report.words) w.term],
        );
        // Pack words are consecutive by position.
        for (final r in rows) {
          final inPack = await WordRepo(db).forPack(r.pack.id);
          expect(inPack.first.term, r.firstTerm);
          expect(inPack.last.term, r.lastTerm);
          final first = inPack.first.position;
          expect(
            [for (final w in inPack) w.position],
            [for (var i = 0; i < inPack.length; i++) first + i],
          );
        }
      });
    }

    test('definitions.txt: POS and pack label data', () async {
      final id = await importFixture('definitions.txt');
      final words = await WordRepo(db).forWordlist(id);
      final wherever = words.firstWhere((w) => w.term == 'wherever');
      expect(wherever.pos, 'adverb');
      expect(wherever.posRaw, 'a');
      final first = (await PackRepo(db).watchRows(id).first).first;
      expect(first.firstTerm, 'abbey');
    });

    test('uses the pack size from settings', () async {
      await (db.update(
        db.appSettings,
      )).write(const AppSettingsCompanion(packSize: Value(20)));
      final id = await importFixture('definitions.txt');
      expect(await PackRepo(db).forWordlist(id), hasLength(50));
    });

    test('name: given name is trimmed; empty falls back to the file', () {
      expect(wordlistName('  GRE list ', 'x.csv'), 'GRE list');
      expect(wordlistName(' ', r'C:\files\definitions.csv'), 'definitions');
      expect(wordlistName('', '.csv'), '.csv');
      expect(wordlistName('', ''), 'Wordlist');
      expect(wordlistName('a' * 250, 'x.csv'), hasLength(200));
    });
  });

  group('R-2 rejected files', () {
    test('empty file → NO_WORDS_FOUND', () async {
      await expectLater(
        service.preview(Uint8List(0)),
        throwsA(
          isA<ImportException>().having(
            (e) => e.error,
            'error',
            ImportError.noWordsFound,
          ),
        ),
      );
    });

    test('file over 5 MB is rejected before parsing', () async {
      await expectLater(
        service.preview(Uint8List(ImportService.maxBytes + 1)),
        throwsA(
          isA<ImportException>().having(
            (e) => e.error,
            'error',
            ImportError.tooLarge,
          ),
        ),
      );
      ImportService.checkSize(ImportService.maxBytes);
    });

    test('undecodable bytes → unreadable', () async {
      await expectLater(
        service.preview(Uint8List.fromList([0xC3, 0x28, 0x81])),
        throwsA(
          isA<ImportException>().having(
            (e) => e.error,
            'error',
            ImportError.unreadable,
          ),
        ),
      );
    });
  });

  test('a failure mid-import leaves no partial rows', () async {
    final report = await service.preview(fixture('sample-columns.csv'));
    final failing = ImportService(
      db: db,
      clock: FixedClock(),
      ids: SeqIds(failAfter: 30),
    );
    await expectLater(
      failing.commit(report, name: 'x', sourceFilename: 'x.csv'),
      throwsStateError,
    );
    expect(await WordlistRepo(db).watchAll().first, isEmpty);
    expect(await WordRepo(db).countAll(), 0);
  });

  test(
    'R-3 delete wordlist removes words, packs, passes; categories remain',
    () async {
      final id = await importFixture('sample-columns.csv');
      final keep = await importFixture('edge-cases.txt');
      final pack = (await PackRepo(db).forWordlist(id)).first;
      final words = await WordRepo(db).forPack(pack.id);
      await PassRepo(db).saveState(
        startPass(
          packId: pack.id,
          direction: Direction.wd,
          wordIds: [for (final w in words) w.id],
          passNumber: 1,
          now: FixedClock().now(),
        ),
        id: 'pass-1',
        now: FixedClock().now(),
      );
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'cat-1',
              name: 'Law',
              key: 'law',
              createdAt: FixedClock().now(),
            ),
          );
      await db
          .update(db.words)
          .write(const WordsCompanion(categoryId: Value('cat-1')));

      await WordlistService(db).delete(id);

      expect(await WordlistRepo(db).get(id), isNull);
      expect(await PackRepo(db).forWordlist(id), isEmpty);
      expect(await WordRepo(db).forWordlist(id), isEmpty);
      expect(await PassRepo(db).get(pack.id, Direction.wd), isNull);
      expect(await db.select(db.categories).get(), hasLength(1));
      expect(await WordRepo(db).forWordlist(keep), hasLength(9));
      await expectLater(
        WordlistService(db).delete(id),
        throwsA(isA<WordlistNotFoundException>()),
      );
    },
  );

  test('rename wordlist', () async {
    final id = await importFixture('edge-cases.txt');
    await WordlistService(db).rename(id, '  My list ');
    expect((await WordlistRepo(db).get(id))!.name, 'My list');
    await WordlistService(db).rename(id, '');
    expect((await WordlistRepo(db).get(id))!.name, 'edge-cases');
    await expectLater(
      WordlistService(db).rename('nope', 'x'),
      throwsA(isA<WordlistNotFoundException>()),
    );
  });

  test('R-4 close and reopen a file database: data and pass intact', () async {
    final dir = await Directory.systemTemp.createTemp('wordpack_r4');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/wordpack.sqlite');

    var fileDatabase = fileDb(file);
    final svc = ImportService(
      db: fileDatabase,
      clock: FixedClock(),
      ids: SeqIds(),
    );
    final report = await svc.preview(fixture('definitions.txt'));
    final id = await svc.commit(report, name: '', sourceFilename: 'd.txt');
    final pack = (await PackRepo(fileDatabase).forWordlist(id))[3];
    final wordIds = [
      for (final w in await WordRepo(fileDatabase).forPack(pack.id)) w.id,
    ];
    // Card 12 with one peek on card 5.
    PassState state = startPass(
      packId: pack.id,
      direction: Direction.wd,
      wordIds: wordIds,
      passNumber: 2,
      now: FixedClock().now(),
    );
    for (var i = 0; i < 11; i++) {
      if (i == 4) state = show(state).$1!;
      state = next(state).$1!;
    }
    await PassRepo(
      fileDatabase,
    ).saveState(state, id: 'pass-1', now: FixedClock().now());
    await fileDatabase.close();

    fileDatabase = fileDb(file);
    addTearDown(fileDatabase.close);
    expect(await WordRepo(fileDatabase).countAll(), 998);
    expect((await SettingsRepo(fileDatabase).get()).packSize, 30);
    final restored = await PassRepo(
      fileDatabase,
    ).loadState(pack.id, Direction.wd, wordIds);
    expect(restored, state);
    expect(restored!.index, 11);
    expect(restored.peeks, 1);
    expect(
      await PassRepo(fileDatabase).loadState(pack.id, Direction.dw, wordIds),
      isNull,
    );
    final open = await PassRepo(fileDatabase).watchForWordlist(id).first;
    expect(open.single.packId, pack.id);
    final rows = await PackRepo(fileDatabase).watchRows(id).first;
    expect(rows[3].openDirections, {Direction.wd});
    expect(rows[3].status(LearnedRule.both), PackStatus.learning);

    // Saving again updates the same row; deleting removes it.
    await PassRepo(
      fileDatabase,
    ).saveState(next(restored).$1!, id: 'pass-2', now: FixedClock().now());
    final again = await PassRepo(fileDatabase).get(pack.id, Direction.wd);
    expect(again!.id, 'pass-1');
    expect(again.idx, 12);
    await PassRepo(fileDatabase).delete(pack.id, Direction.wd);
    expect(await PassRepo(fileDatabase).get(pack.id, Direction.wd), isNull);
  });
}
