import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/services/tagging_service.dart';

import '../support/app.dart';
import '../support/test_db.dart';

/// Scrolls the (lazily built) page until [finder] exists, then shows it.
Future<void> reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .last,
    );
  }
  await tester.ensureVisible(finder.last);
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  await reveal(tester, find.text(text));
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

Future<void> tapTooltip(WidgetTester tester, String tooltip) async {
  await reveal(tester, find.byTooltip(tooltip));
  await tester.tap(find.byTooltip(tooltip).first);
  await tester.pumpAndSettle();
}

/// sample-columns.csv (2 packs of 30) with pack 1 Learned.
Future<void> importLearned(WidgetTester tester, TestApp app) async {
  app.picker.addFixture('sample-columns.csv');
  await tapText(tester, 'Import CSV');
  await tapText(tester, 'Import 60 words');
  final db = app.db;
  await (db.update(
    db.words,
  )..where((w) => w.position.isSmallerThanValue(30))).write(
    const WordsCompanion(masteredWd: Value(true), masteredDw: Value(true)),
  );
  await (db.update(db.packs)..where((p) => p.number.equals(1))).write(
    const PacksCompanion(
      masteryWd: Value(Mastery.mastered),
      masteryDw: Value(Mastery.mastered),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.text('Settings').last);
  await tester.pumpAndSettle();
}

Future<AppSetting> settingsRow(TestApp app) =>
    app.db.select(app.db.appSettings).getSingle();

void main() {
  group('M6 settings', () {
    testApp('I-11 pack size 20: preview, rebuild, pack 1 still learned', (
      tester,
      app,
    ) async {
      await importLearned(tester, app);
      expect(find.text('1 of 2 packs learned'), findsOneWidget);
      await openSettings(tester);
      expect(find.text('30 words per pack'), findsOneWidget);

      await tapText(tester, 'Pack size');
      for (var i = 0; i < 10; i++) {
        await tester.tap(find.byTooltip('−'));
        await tester.pump();
      }
      expect(find.text('20'), findsOneWidget);
      await tapText(tester, 'Save');

      expect(find.text('Change pack size to 20?'), findsOneWidget);
      expect(
        find.textContaining('sample-columns: 2 → 3 packs'),
        findsOneWidget,
      );
      await tapText(tester, 'Rebuild packs');
      expect(find.text('20 words per pack'), findsOneWidget);

      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      expect(find.text('1 of 3 packs learned'), findsOneWidget);
      expect(find.text('Learned'), findsOneWidget);
    });

    testApp('cancelling the pack-size change changes nothing', (
      tester,
      app,
    ) async {
      await importLearned(tester, app);
      await openSettings(tester);
      await tapText(tester, 'Pack size');
      await tester.tap(find.byTooltip('+'));
      await tester.pump();
      await tapText(tester, 'Save');
      await tapText(tester, 'Cancel');
      expect((await settingsRow(app)).packSize, 30);
    });

    testApp('learned rule, direction, POS, demote and theme', (
      tester,
      app,
    ) async {
      await importLearned(tester, app);
      await openSettings(tester);

      await tapText(tester, 'Definition → Word');
      await tapText(tester, 'A clean Word → Definition pass');
      await tapText(tester, 'Show part of speech');
      await tapText(tester, 'Peeks during review demote the pack');
      await tapText(tester, 'Dark');
      final s = await settingsRow(app);
      expect(s.learnedRule, LearnedRule.wdOnly);
      expect(s.defaultDirection, Direction.dw);
      expect(s.showPos, isFalse);
      expect(s.demoteOnReveal, isTrue);
      expect(s.theme, 'dark');
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );
    });

    testApp('rename and delete a wordlist', (tester, app) async {
      await importLearned(tester, app);
      await openSettings(tester);
      await tapTooltip(tester, 'Rename');
      await tester.enterText(find.byKey(const ValueKey('prompt-field')), 'GRE');
      await tapText(tester, 'Save');
      expect(find.text('GRE'), findsOneWidget);

      await tapTooltip(tester, 'Delete');
      expect(find.text('Delete “GRE”?'), findsOneWidget);
      expect(find.textContaining('60 words, 2 packs'), findsOneWidget);
      await tapText(tester, 'Delete list');
      expect(await app.db.select(app.db.wordlists).get(), isEmpty);
    });

    testApp('backup export, then restore after a change', (tester, app) async {
      await importLearned(tester, app);
      await openSettings(tester);
      await tapText(tester, 'Export backup');
      expect(find.text('Backup saved.'), findsOneWidget);
      final json = app.backups.saved['wordpack-backup-2026-09-24.json']!;
      expect((jsonDecode(json) as Map)['app'], 'wordpack');

      // Change something, then restore the backup.
      await tapTooltip(tester, 'Delete');
      await tapText(tester, 'Delete list');
      expect(await app.db.select(app.db.words).get(), isEmpty);

      app.backups.toOpen = json;
      await tapText(tester, 'Restore backup');
      expect(find.text('Restore this backup?'), findsOneWidget);
      expect(find.textContaining('1 wordlist · 60 words'), findsOneWidget);
      await tapText(tester, 'Replace and restore');
      expect(find.text('Backup restored.'), findsOneWidget);
      expect(await app.db.select(app.db.words).get(), hasLength(60));
    });

    testApp('restoring something that is not a backup', (tester, app) async {
      await openSettings(tester);
      app.backups.toOpen = '{"app": "other"}';
      await tapText(tester, 'Restore backup');
      expect(
        find.text('This file isn’t a WordPack backup, or it’s damaged.'),
        findsOneWidget,
      );
    });

    testApp('keyboard shortcut list', (tester, app) async {
      await openSettings(tester);
      await tapText(tester, 'Keyboard shortcuts');
      expect(find.text('Space / Enter'), findsOneWidget);
      await tapText(tester, 'Close');
    });

    testApp('settings meet tap-target and label guidelines', (
      tester,
      app,
    ) async {
      await importLearned(tester, app);
      await openSettings(tester);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    }, semantics: true);
  });

  group('M6 manage categories', () {
    Future<void> seed(WidgetTester tester, TestApp app) async {
      await importLearned(tester, app);
      final db = app.db;
      final tags = TaggingService(db: db, clock: FixedClock(), ids: _Ids());
      final w = await (db.select(
        db.words,
      )..where((x) => x.position.isSmallerThanValue(3))).get();
      await tags.assign(w[0].id, category: 'Emotions', subcategory: 'Anger');
      await tags.assign(w[1].id, category: 'Feelings', subcategory: 'Anger');
      await tags.assign(w[2].id, category: 'Feelings');
      await openSettings(tester);
      await tapText(tester, 'Manage categories');
    }

    Future<void> menu(WidgetTester tester, String name, String action) async {
      await tester.tap(find.byTooltip(name).first);
      await tester.pumpAndSettle();
      await tapText(tester, action);
    }

    testApp('rename, and a clash suggests merge', (tester, app) async {
      await seed(tester, app);
      expect(find.text('Emotions'), findsOneWidget);
      expect(find.text('Anger'), findsNWidgets(2));

      await menu(tester, 'Emotions', 'Rename');
      await tester.enterText(
        find.byKey(const ValueKey('prompt-field')),
        'Moods',
      );
      await tapText(tester, 'Save');
      expect(find.text('Moods'), findsOneWidget);

      await menu(tester, 'Moods', 'Rename');
      await tester.enterText(
        find.byKey(const ValueKey('prompt-field')),
        'feelings',
      );
      await tapText(tester, 'Save');
      expect(
        find.text('“feelings” already exists here. Use Merge instead.'),
        findsOneWidget,
      );
    });

    testApp('merge Feelings into Emotions', (tester, app) async {
      await seed(tester, app);
      await menu(tester, 'Feelings', 'Merge into…');
      await tapText(tester, 'Emotions');
      expect(find.text('Feelings'), findsNothing);
      expect(find.text('Anger'), findsOneWidget, reason: 'merged by name');
      expect(find.text('3 words'), findsOneWidget);
    });

    testApp('delete a category', (tester, app) async {
      await seed(tester, app);
      await menu(tester, 'Feelings', 'Delete');
      expect(find.text('Delete “Feelings”?'), findsOneWidget);
      expect(
        find.text(
          'Its 1 subcategory goes with it. 2 words become uncategorised; '
          'their tone and trait tags stay.',
        ),
        findsOneWidget,
      );
      await tapText(tester, 'Delete category');
      expect(find.text('Feelings'), findsNothing);
      expect(find.text('Anger'), findsOneWidget);
    });

    testApp('no categories yet', (tester, app) async {
      await openSettings(tester);
      await tapText(tester, 'Manage categories');
      expect(
        find.text(
          'No categories yet. Add them while reviewing a learned pack.',
        ),
        findsOneWidget,
      );
    });
  });

  testApp(
    'learn screen: ? opens the shortcut list; missing pack is friendly',
    (tester, app) async {
      await importLearned(tester, app);
      await tapText(tester, 'Pack 2');
      await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(find.text('Keyboard shortcuts'), findsOneWidget);
      await tapText(tester, 'Close');
    },
    size: const Size(1280, 800),
  );
}

class _Ids extends SeqIds {
  @override
  String newId() => 'x-${super.newId()}';
}
