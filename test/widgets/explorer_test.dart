import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/services/tagging_service.dart';
import 'package:wordpack/ui/card/word_card.dart';
import 'package:wordpack/ui/tagging/quick_tag_bar.dart';

import '../support/app.dart';
import '../support/test_db.dart';

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

/// Imports sample-columns.csv (packs: abbey–advent, adverse–…), marks pack 1
/// Learned, and files abbey and abide under Religion › Places.
Future<void> setUpList(WidgetTester tester, TestApp app) async {
  app.picker.addFixture('sample-columns.csv');
  await tapText(tester, 'Import CSV');
  await tapText(tester, 'Import 60 words');
  final db = app.db;
  await (db.update(db.packs)..where((p) => p.number.equals(1))).write(
    const PacksCompanion(
      masteryWd: Value(Mastery.mastered),
      masteryDw: Value(Mastery.mastered),
    ),
  );
  final tags = TaggingService(db: db, clock: FixedClock(), ids: _Ids());
  for (final term in ['abide', 'abbey']) {
    final w = await (db.select(
      db.words,
    )..where((x) => x.term.equals(term))).getSingle();
    await tags.assign(w.id, category: 'Religion', subcategory: 'Places');
  }
  await tester.pumpAndSettle();
}

Future<void> openTree(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open word tree').first);
  await tester.pumpAndSettle();
}

Future<void> expand(WidgetTester tester, String title) async {
  await tester.tap(find.byTooltip('Expand $title'));
  await tester.pumpAndSettle();
}

Future<void> snapshotPacks(TestApp app, List<Pack> into) async =>
    into.addAll(await app.db.select(app.db.packs).get());

void main() {
  group('M5 tree', () {
    testApp('phone: the tree opens in a drawer with counts', (
      tester,
      app,
    ) async {
      await setUpList(tester, app);
      await openTree(tester);
      Finder inTree(String t) =>
          find.descendant(of: find.byType(Drawer), matching: find.text(t));
      expect(inTree('sample-columns'), findsOneWidget);
      expect(inTree('60'), findsOneWidget);

      await expand(tester, 'sample-columns');
      for (final t in ['Packs', 'Categories', 'Tags', 'Uncategorised']) {
        expect(find.text(t), findsOneWidget);
      }
      expect(find.text('1 / 2'), findsOneWidget, reason: 'packs learned');
      expect(find.text('58'), findsOneWidget, reason: 'uncategorised');

      await expand(tester, 'Packs');
      expect(inTree('Pack 1'), findsOneWidget);
      expect(find.byTooltip('Study pack 1'), findsOneWidget);

      // Expansion is saved.
      final ui = await app.db.select(app.db.uiState).getSingle();
      expect(ui.expandedNodeIds, hasLength(2));
    });

    testApp('I-9 Religion › Places: 1 / 2, swipe, reveal, statuses unchanged', (
      tester,
      app,
    ) async {
      await setUpList(tester, app);
      final before = <Pack>[];
      await snapshotPacks(app, before);

      await openTree(tester);
      await expand(tester, 'sample-columns');
      await expand(tester, 'Categories');
      await expand(tester, 'Religion');
      await tapText(tester, 'Places');

      expect(
        find.text('sample-columns › Categories › Religion › Places'),
        findsOneWidget,
      );
      expect(find.text('2 words'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text('abbey'), findsOneWidget, reason: 'alphabetical');
      expect(find.text('Religion › Places'), findsWidgets);

      // Tap to reveal.
      await tester.tap(find.byType(WordCard).first);
      await tester.pumpAndSettle();
      expect(find.text('a monastery ruled by an abbot'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2'), findsOneWidget);
      expect(find.text('abide'), findsOneWidget);

      // Browsing changed nothing (EXP-4).
      final after = await app.db.select(app.db.packs).get();
      expect(
        [for (final p in after) (p.masteryWd, p.masteryDw)],
        [for (final p in before) (p.masteryWd, p.masteryDw)],
      );
      expect(await app.db.select(app.db.passSessions).get(), isEmpty);
    });

    testApp('tagging in the explorer updates the tree counts live', (
      tester,
      app,
    ) async {
      await setUpList(tester, app);
      await openTree(tester);
      await expand(tester, 'sample-columns');
      await expand(tester, 'Tags');
      await tapText(tester, 'Packs');
      expect(find.byType(QuickTagBar), findsOneWidget, reason: 'pack 1');

      await tapText(tester, 'Negative');
      await openTree(tester);
      final negativeRow = find.ancestor(
        of: find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Negative'),
        ),
        matching: find.byType(InkWell),
      );
      expect(
        find.descendant(of: negativeRow.first, matching: find.text('1')),
        findsOneWidget,
      );
    });

    testApp('no tag controls for words of a pack that is not Learned', (
      tester,
      app,
    ) async {
      await setUpList(tester, app);
      await openTree(tester);
      await expand(tester, 'sample-columns');
      await expand(tester, 'Packs');
      await tapText(tester, 'Pack 2');
      expect(find.byType(QuickTagBar), findsNothing);
      expect(find.text('1 / 30'), findsOneWidget);
    });

    testApp('list mode, then a row opens card mode at that word', (
      tester,
      app,
    ) async {
      await setUpList(tester, app);
      await openTree(tester);
      await expand(tester, 'sample-columns');
      await tapText(tester, 'Uncategorised');
      expect(find.text('58 words'), findsOneWidget);

      await tester.tap(find.byTooltip('List'));
      await tester.pumpAndSettle();
      expect(find.byType(WordCard), findsNothing);
      expect(
        (await app.db.select(app.db.uiState).getSingle()).viewerMode,
        'list',
      );
      await tester.tap(find.textContaining('abound').first);
      await tester.pumpAndSettle();
      expect(find.byType(WordCard), findsWidgets);
      expect(find.text('abound'), findsOneWidget);
    });

    testApp('search finds words by term or definition', (tester, app) async {
      await setUpList(tester, app);
      await openTree(tester);
      await tester.enterText(
        find.byKey(const ValueKey('tree-search')),
        'abbot',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('Search: “abbot”'), findsOneWidget);
      expect(find.text('1 word'), findsOneWidget);
      expect(find.text('abbey'), findsOneWidget);
    });

    testApp('Explore tab with nothing selected', (tester, app) async {
      await setUpList(tester, app);
      await tester.tap(find.text('Explore').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Choose a group in the word tree to browse its words.'),
        findsOneWidget,
      );
    });

    testApp('desktop: permanent tree, keyboard navigation', (
      tester,
      app,
    ) async {
      await setUpList(tester, app);
      expect(find.text('sample-columns'), findsWidgets);

      // The expand arrow focuses the tree; then ←/→ collapse and expand,
      // ↓ moves, Enter opens.
      await expand(tester, 'sample-columns');
      expect(find.text('Packs'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(find.text('Packs'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('Packs'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('sample-columns › Packs'), findsOneWidget);
    }, size: const Size(1280, 800));

    testApp('tree rows meet tap-target and label guidelines', (
      tester,
      app,
    ) async {
      await setUpList(tester, app);
      await openTree(tester);
      await expand(tester, 'sample-columns');
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    }, semantics: true);
  });
}

class _Ids extends SeqIds {
  @override
  String newId() => 'x-${super.newId()}';
}
