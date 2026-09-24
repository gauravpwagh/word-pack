import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/repositories/pack_repo.dart';
import 'package:wordpack/data/repositories/pass_repo.dart';
import 'package:wordpack/data/repositories/word_repo.dart';
import 'package:wordpack/domain/learning.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/ui/wordlist/pack_tile.dart';

import '../support/app.dart';
import '../support/test_db.dart';

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  group('M2 import flow', () {
    testApp('welcome → preview → import → wordlist home', (tester, app) async {
      app.picker.addFixture('definitions.txt');

      await tapText(tester, 'Import CSV');

      expect(find.text('Import preview'), findsOneWidget);
      expect(find.text('File: definitions.txt'), findsOneWidget);
      expect(
        find.text('Detected: dash lines (word - pos. definition)'),
        findsOneWidget,
      );
      expect(find.text('998 words ready'), findsOneWidget);
      expect(
        find.text('noun 501 · adj. 336 · verb 149 · adv. 12'),
        findsOneWidget,
      );
      expect(find.text('No lines skipped'), findsOneWidget);
      expect(find.text('No duplicates'), findsOneWidget);
      expect(find.text('34 packs of 30 (last pack 8)'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).last).controller!.text,
        'definitions',
      );

      await tapText(tester, 'Import 998 words');

      expect(find.text('definitions'), findsOneWidget); // app bar title
      expect(find.text('0 of 34 packs learned'), findsOneWidget);
      expect(find.text('998 words'), findsOneWidget);
      expect(
        find.text('Continue · Pack 1 · Word → Definition'),
        findsOneWidget,
      );
      expect(find.text('Pack 1'), findsOneWidget);
      expect(find.byType(PackTile), findsWidgets);
      expect(find.text('New'), findsWidgets);
      expect(await WordRepo(app.db).countAll(), 998);
    });

    testApp('renamed list, skipped lines and duplicates', (tester, app) async {
      app.picker.addFixture('edge-cases.txt');
      await tapText(tester, 'Import CSV');

      expect(find.text('9 words ready'), findsOneWidget);
      expect(find.text('1 line skipped'), findsOneWidget);
      expect(
        find.text(
          'Line 11: “missing separator line” — no “ - ” separator found',
        ),
        findsOneWidget,
      );
      expect(find.text('1 duplicate removed'), findsOneWidget);
      expect(find.text('1 pack of 30 (last pack 9)'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'Tricky words');
      await tapText(tester, 'Import 9 words');

      expect(find.text('Tricky words'), findsOneWidget);
      final lists = await app.db.select(app.db.wordlists).get();
      expect(lists.single.name, 'Tricky words');
    });

    testApp('columns CSV shows its format', (tester, app) async {
      app.picker.addFixture('sample-columns.csv');
      await tapText(tester, 'Import CSV');
      expect(find.text('Detected: CSV columns'), findsOneWidget);
      expect(find.text('2 packs of 30'), findsOneWidget);
    });

    testApp('cancel saves nothing and returns to welcome', (tester, app) async {
      app.picker.addFixture('sample-columns.csv');
      await tapText(tester, 'Import CSV');
      await tapText(tester, 'Cancel');

      expect(find.text('Import CSV'), findsOneWidget);
      expect(await app.db.select(app.db.wordlists).get(), isEmpty);
    });

    testApp('closing the picker changes nothing', (tester, app) async {
      await tapText(tester, 'Import CSV');
      expect(app.picker.picks, 1);
      expect(find.text('Import CSV'), findsOneWidget);
    });

    testApp('a file without words shows an error and a retry', (
      tester,
      app,
    ) async {
      app.picker.add('empty.csv', const <int>[]);
      app.picker.add('bad.txt', const [0xC3, 0x28, 0x81]);
      app.picker.addFixture('sample-columns.csv');

      await tapText(tester, 'Import CSV');
      expect(find.textContaining('No words found.'), findsOneWidget);

      await tapText(tester, 'Choose another file');
      expect(find.textContaining('can’t be read'), findsOneWidget);

      await tapText(tester, 'Choose another file');
      expect(find.text('60 words ready'), findsOneWidget);
    });

    testApp('import from the rail with nothing picked yet', (
      tester,
      app,
    ) async {
      await tester.tap(find.text('Import').first);
      await tester.pumpAndSettle();
      expect(find.text('Choose a file'), findsOneWidget);

      app.picker.addFixture('sample-columns.csv');
      await tapText(tester, 'Choose a file');
      expect(find.text('60 words ready'), findsOneWidget);
    }, size: const Size(1280, 800));
  });

  group('M2 wordlist home', () {
    testApp('resume banner, pack status and switching lists', (
      tester,
      app,
    ) async {
      app.picker.addFixture('sample-columns.csv');
      await tapText(tester, 'Import CSV');
      await tapText(tester, 'Import 60 words');

      // An unfinished pass on pack 2 at card 3.
      final listId = (await app.db.select(app.db.wordlists).get()).single.id;
      final pack2 = (await PackRepo(app.db).forWordlist(listId))[1];
      final ids = [
        for (final w in await WordRepo(app.db).forPack(pack2.id)) w.id,
      ];
      var state = startPass(
        packId: pack2.id,
        direction: Direction.dw,
        wordIds: ids,
        passNumber: 1,
        now: FixedClock().now(),
      );
      state = next(next(state).$1!).$1!;
      await PassRepo(
        app.db,
      ).saveState(state, id: 'pass', now: FixedClock().now());
      await tester.pumpAndSettle();

      expect(
        find.text('Resume Pack 2 · Definition → Word · card 3 / 30'),
        findsOneWidget,
      );
      expect(
        find.text('Continue · Pack 2 · Definition → Word'),
        findsOneWidget,
      );
      expect(find.text('Learning'), findsOneWidget);

      // A second list: the switcher appears and the newest list is shown.
      app.picker.addFixture('edge-cases.txt');
      await tester.tap(find.byTooltip('Import CSV'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Import 9 words');
      expect(find.text('edge-cases'), findsOneWidget);

      await tester.tap(find.byTooltip('Switch wordlist'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('sample-columns').last);
      await tester.pumpAndSettle();
      expect(find.text('0 of 2 packs learned'), findsOneWidget);
    });

    testApp('tapping a pack opens it for learning', (tester, app) async {
      app.picker.addFixture('sample-columns.csv');
      await tapText(tester, 'Import CSV');
      await tapText(tester, 'Import 60 words');

      await tester.tap(find.byType(PackTile).first);
      await tester.pumpAndSettle();
      expect(find.text('1 / 30'), findsOneWidget);
      expect(find.text('Pack 1 · abbey – advent'), findsOneWidget);
    });
  });
}
