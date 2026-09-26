import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/data/repositories/pass_repo.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/ui/card/word_card.dart';
import 'package:wordpack/ui/wordlist/pack_tile.dart';

import '../support/app.dart';

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

/// Imports sample-columns.csv (2 packs of 30) and opens pack 1 via Continue.
Future<void> openPack1(WidgetTester tester, TestApp app) async {
  app.picker.addFixture('sample-columns.csv');
  await tapText(tester, 'Import CSV');
  await tapText(tester, 'Import 60 words');
  await tapText(tester, 'Continue · Pack 1 · Word → Definition');
}

Future<void> tapNext(WidgetTester tester, [int times = 1]) async {
  for (var i = 0; i < times; i++) {
    await tester.tap(find.byKey(const ValueKey('next')));
    await tester.pumpAndSettle();
  }
}

Future<void> tapShow(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('show')));
  await tester.pumpAndSettle();
}

bool showEnabled(WidgetTester tester) =>
    tester
        .widget<ButtonStyleButton>(find.byKey(const ValueKey('show')))
        .onPressed !=
    null;

void main() {
  group('M3 learn screen', () {
    testApp('W-3 Show → Shown (disabled), peek counter, summary at the end', (
      tester,
      app,
    ) async {
      await openPack1(tester, app);
      expect(find.text('Pack 1 · abbey – advent'), findsOneWidget);
      expect(find.text('1 / 30'), findsOneWidget);
      expect(find.text('Peeks this pass: 0'), findsOneWidget);
      expect(find.text('abbey'), findsOneWidget);
      expect(showEnabled(tester), isTrue);

      await tapShow(tester);
      expect(find.text('Shown'), findsOneWidget);
      expect(showEnabled(tester), isFalse);
      expect(find.text('Peeks this pass: 1'), findsOneWidget);
      expect(
        find.text('This pass won’t count — finish it, then repeat the pack.'),
        findsOneWidget,
      );

      await tapNext(tester);
      expect(find.text('2 / 30'), findsOneWidget);
      expect(find.text('Show'), findsOneWidget);

      await tapNext(tester, 29);
      expect(find.text('Pass finished with 1 peek: abbey'), findsOneWidget);
      expect(find.text('Repeat pack'), findsOneWidget);
      expect(find.text('Switch direction'), findsOneWidget);
      expect(find.text('Back to wordlist'), findsOneWidget);
      expect(find.textContaining('ategor'), findsNothing, reason: 'D-9');
    });

    testApp('clean WD → start DW → clean → Pack 1 learned!', (
      tester,
      app,
    ) async {
      await openPack1(tester, app);
      await tapNext(tester, 30);
      expect(
        find.text('Clean pass — Pack 1 · Word → Definition mastered.'),
        findsOneWidget,
      );

      await tapText(tester, 'Start Definition → Word');
      expect(find.text('1 / 30'), findsOneWidget);
      expect(
        find.text('a monastery ruled by an abbot'),
        findsOneWidget,
        reason: 'DW shows the definition first',
      );
      await tapNext(tester, 30);
      expect(find.text('Pack 1 learned!'), findsOneWidget);
      expect(find.text('Next pack'), findsOneWidget);
      expect(find.text('Review this pack'), findsOneWidget);

      await tapText(tester, 'Review this pack');
      expect(find.text('Review'), findsOneWidget);
      expect(find.text('1 / 30'), findsOneWidget);
    });

    testApp('Next pack from the summary; back to the wordlist', (
      tester,
      app,
    ) async {
      await openPack1(tester, app);
      await tapNext(tester, 30);
      await tapText(tester, 'Next pack');
      expect(find.textContaining('Pack 2 · '), findsOneWidget);

      await tapNext(tester, 30);
      await tapText(tester, 'Back to wordlist');
      expect(find.text('0 of 2 packs learned'), findsOneWidget);
      expect(find.text('Learning'), findsNWidgets(2));
    });

    testApp('Repeat pack after peeks starts again at card 1', (
      tester,
      app,
    ) async {
      await openPack1(tester, app);
      await tapShow(tester);
      await tapNext(tester, 30);
      await tapText(tester, 'Repeat pack');
      expect(find.text('1 / 30'), findsOneWidget);
      expect(find.text('Peeks this pass: 0'), findsOneWidget);
    });

    testApp('I-5 switching direction mid-pass asks, then restarts in DW', (
      tester,
      app,
    ) async {
      await openPack1(tester, app);
      await tapNext(tester, 3);
      expect(find.text('4 / 30'), findsOneWidget);

      await tester.tap(find.text('Def → Word'));
      await tester.pumpAndSettle();
      expect(find.text('Switch to Definition → Word?'), findsOneWidget);
      expect(find.text('This pass will restart.'), findsOneWidget);

      await tapText(tester, 'Cancel');
      expect(find.text('4 / 30'), findsOneWidget);

      await tester.tap(find.text('Def → Word'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Switch');
      expect(find.text('1 / 30'), findsOneWidget);
      expect(find.text('a monastery ruled by an abbot'), findsOneWidget);
    });

    testApp('on card 1 with no peeks the direction switches directly', (
      tester,
      app,
    ) async {
      await openPack1(tester, app);
      await tester.tap(find.text('Def → Word'));
      await tester.pumpAndSettle();
      expect(find.text('Switch to Definition → Word?'), findsNothing);
      expect(find.text('a monastery ruled by an abbot'), findsOneWidget);
    });

    testApp('Previous restores the reveal and never adds a peek', (
      tester,
      app,
    ) async {
      await openPack1(tester, app);
      final previous = find.ancestor(
        of: find.byTooltip('Previous'),
        matching: find.byType(IconButton),
      );
      expect(tester.widget<IconButton>(previous).onPressed, isNull);
      await tapShow(tester);
      await tapNext(tester);
      await tester.tap(find.byTooltip('Previous'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 30'), findsOneWidget);
      expect(find.text('Shown'), findsOneWidget);
      expect(find.text('Peeks this pass: 1'), findsOneWidget);
    });

    testApp('tap card = Show; swipe left = Next; swipe right = Previous', (
      tester,
      app,
    ) async {
      await openPack1(tester, app);
      await tester.tap(find.byType(WordCard));
      await tester.pumpAndSettle();
      expect(find.text('Peeks this pass: 1'), findsOneWidget);

      await tester.drag(find.byType(WordCard), const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(find.text('2 / 30'), findsOneWidget);

      await tester.drag(find.byType(WordCard), const Offset(200, 0));
      await tester.pumpAndSettle();
      expect(find.text('1 / 30'), findsOneWidget);
    });

    testApp(
      'keyboard: Space shows, → next, ← previous, D switches',
      (tester, app) async {
        await openPack1(tester, app);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(find.text('2 / 30'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(find.text('Shown'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
        expect(find.text('1 / 30'), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
        await tester.pumpAndSettle();
        expect(find.text('Switch to Definition → Word?'), findsOneWidget);
      },
      size: const Size(1280, 800),
    );

    testApp('I-4 leaving mid-pass: resume banner returns to the same card', (
      tester,
      app,
    ) async {
      await openPack1(tester, app);
      await tapNext(tester, 4);
      await tapShow(tester);
      await tapNext(tester, 7);
      expect(find.text('12 / 30'), findsOneWidget);

      // Leave via the Learn tab (the app bar has no back arrow here).
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Resume Pack 1 · Word → Definition · card 12 / 30'),
        findsOneWidget,
      );
      expect(find.byType(PackTile), findsNWidgets(2));
      final saved = await PassRepo(app.db).get(
        (await app.db.select(app.db.packs).get())
            .firstWhere((p) => p.number == 1)
            .id,
        Direction.wd,
      );
      expect(saved!.idx, 11);

      await tapText(tester, 'Resume Pack 1 · Word → Definition · card 12 / 30');
      expect(find.text('12 / 30'), findsOneWidget);
      expect(find.text('Peeks this pass: 1'), findsOneWidget);
    });

    testApp('learn screen meets tap-target and label guidelines', (
      tester,
      app,
    ) async {
      await openPack1(tester, app);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    }, semantics: true);
  });

  group('D-34 study buttons', () {
    Future<void> buttonsOff(TestApp app) => app.db
        .update(app.db.appSettings)
        .write(const AppSettingsCompanion(studyButtons: Value(false)));

    testApp('off: no button bar, a hint, tap and swipe anywhere', (
      tester,
      app,
    ) async {
      await buttonsOff(app);
      await openPack1(tester, app);
      expect(find.byKey(const ValueKey('show')), findsNothing);
      expect(find.byKey(const ValueKey('next')), findsNothing);
      expect(find.byKey(const ValueKey('gesture-hint')), findsOneWidget);

      await tester.tap(find.byType(WordCard));
      await tester.pumpAndSettle();
      expect(find.text('Peeks this pass: 1'), findsOneWidget);

      // A swipe on the empty space below the card works too.
      final below = tester.getBottomLeft(find.byType(WordCard));
      await tester.dragFrom(
        Offset(below.dx + 150, below.dy + 180),
        const Offset(-200, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('2 / 30'), findsOneWidget);
    });

    testApp('the card follows the finger and springs back', (
      tester,
      app,
    ) async {
      await buttonsOff(app);
      await openPack1(tester, app);
      final start = tester.getTopLeft(find.byType(WordCard));
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(WordCard)),
      );
      await gesture.moveBy(const Offset(-20, 0));
      await gesture.moveBy(const Offset(-20, 0));
      await tester.pump();
      expect(tester.getTopLeft(find.byType(WordCard)).dx, lessThan(start.dx));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byType(WordCard)), start);
      expect(find.text('1 / 30'), findsOneWidget, reason: 'under 60 px');
    });

    testApp(
      'the hint counts finished passes and stops after three',
      (tester, app) async {
        await buttonsOff(app);
        await app.db
            .update(app.db.uiState)
            .write(const UiStateCompanion(gestureHintPasses: Value(2)));
        await openPack1(tester, app);
        expect(find.byKey(const ValueKey('gesture-hint')), findsOneWidget);
        for (var i = 0; i < 30; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
          await tester.pumpAndSettle();
        }
        expect(
          (await app.db.select(app.db.uiState).getSingle()).gestureHintPasses,
          3,
        );
        await tapText(tester, 'Learn');
        await tapText(tester, 'Pack 2');
        expect(find.text('1 / 30'), findsOneWidget);
        expect(find.byKey(const ValueKey('gesture-hint')), findsNothing);
      },
      size: const Size(1280, 800),
    );

    testApp('a screen reader always gets the buttons and card actions', (
      tester,
      app,
    ) async {
      await buttonsOff(app);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(accessibleNavigation: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await openPack1(tester, app);
      expect(find.byKey(const ValueKey('show')), findsOneWidget);
      expect(find.byKey(const ValueKey('gesture-hint')), findsNothing);
      final ids =
          tester
              .getSemantics(find.byType(WordCard))
              .getSemanticsData()
              .customSemanticsActionIds ??
          const <int>[];
      expect([
        for (final id in ids) CustomSemanticsAction.getAction(id)!.label,
      ], containsAll(['Show', 'Next']));
    }, semantics: true);
  });
}
