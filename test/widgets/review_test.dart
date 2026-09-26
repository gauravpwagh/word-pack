import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/ui/card/dashed_border_painter.dart';
import 'package:wordpack/ui/tagging/category_row.dart';
import 'package:wordpack/ui/tagging/quick_tag_bar.dart';
import 'package:wordpack/ui/theme/wp_colors.dart';

import '../support/app.dart';

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

Future<void> tapNext(WidgetTester tester, [int times = 1]) async {
  for (var i = 0; i < times; i++) {
    await tester.tap(find.byKey(const ValueKey('next')));
    await tester.pumpAndSettle();
  }
}

/// Imports definitions.txt, marks pack 1 Learned, and opens it (Review).
Future<void> reviewPack1(WidgetTester tester, TestApp app) async {
  app.picker.addFixture('definitions.txt');
  await tapText(tester, 'Import CSV');
  await tapText(tester, 'Import 998 words');
  await (app.db.update(app.db.packs)..where((p) => p.number.equals(1))).write(
    const PacksCompanion(
      masteryWd: Value(Mastery.mastered),
      masteryDw: Value(Mastery.mastered),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pack 1'));
  await tester.pumpAndSettle();
}

Future<Word> wordNamed(TestApp app, String term) async => (await (app.db.select(
  app.db.words,
)..where((w) => w.term.equals(term))).get()).single;

Future<void> choose(WidgetTester tester, String fieldKey, String text) async {
  final field = find.byKey(ValueKey(fieldKey));
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.enterText(field, text);
  await tester.pumpAndSettle();
}

void main() {
  group('M4 review', () {
    testApp('I-6 learning a pack that is not Learned: tags, no categories', (
      tester,
      app,
    ) async {
      app.picker.addFixture('sample-columns.csv');
      await tapText(tester, 'Import CSV');
      await tapText(tester, 'Import 60 words');
      await tapText(tester, 'Continue · Pack 1 · Word → Definition');
      expect(find.byType(QuickTagBar), findsOneWidget);
      expect(find.byType(CategoryRow), findsNothing);
      expect(find.text('Review'), findsNothing);
      expect(find.textContaining('ategor'), findsNothing);

      // Tag buttons and keys 1–5 work while learning (D-32).
      await tapText(tester, 'Counter-intuitive');
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.pumpAndSettle();
      final abbey = await wordNamed(app, 'abbey');
      expect(abbey.tone, Tone.negative);
      expect(abbey.counterIntuitive, isTrue);

      // C does not open a category field.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.pumpAndSettle();
      expect(find.byType(CategoryRow), findsNothing);
    });

    testApp('I-7 accuse: Negative + Counter-intuitive, then Negative off', (
      tester,
      app,
    ) async {
      await reviewPack1(tester, app);
      expect(find.text('Review'), findsOneWidget);
      expect(find.byType(QuickTagBar), findsOneWidget);
      await tapNext(tester, 21);
      expect(find.text('accuse'), findsOneWidget);

      await tapText(tester, 'Negative');
      await tapText(tester, 'Counter-intuitive');

      const wp = WpColors.light;
      final edge = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byKey(const ValueKey('tone-edge')),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(edge.color, wp.negative);
      expect(
        tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .any((p) => p.foregroundPainter is DashedBorderPainter),
        isTrue,
      );
      expect(find.byTooltip('Counter-intuitive'), findsOneWidget);
      var accuse = await wordNamed(app, 'accuse');
      expect(accuse.tone, Tone.negative);
      expect(accuse.counterIntuitive, isTrue);

      // Tapping Negative again removes the edge; the badge stays.
      await tapText(tester, 'Negative');
      expect(find.byKey(const ValueKey('tone-edge')), findsNothing);
      expect(find.byTooltip('Counter-intuitive'), findsOneWidget);
      accuse = await wordNamed(app, 'accuse');
      expect(accuse.tone, isNull);
      expect(accuse.counterIntuitive, isTrue);
    });

    testApp('I-8 abbey → Religion › Places; acclaim reuses both', (
      tester,
      app,
    ) async {
      await reviewPack1(tester, app);
      expect(find.text('abbey'), findsOneWidget);

      await choose(tester, 'category-field', 'Religion');
      await tapText(tester, 'Create “Religion”');
      await choose(tester, 'subcategory-field', 'Places');
      await tapText(tester, 'Create “Places”');
      expect(find.text('Religion › Places'), findsOneWidget);

      final abbey = await wordNamed(app, 'abbey');
      final cats = await app.db.select(app.db.categories).get();
      expect(abbey.categoryId, cats.firstWhere((c) => c.name == 'Religion').id);
      expect(
        abbey.subcategoryId,
        cats.firstWhere((c) => c.name == 'Places').id,
      );

      await tapNext(tester, 14);
      expect(find.text('acclaim'), findsOneWidget);
      expect(find.text('Religion › Places'), findsNothing);

      await choose(tester, 'category-field', 're');
      expect(find.widgetWithText(ListTile, 'Religion'), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, 'Religion'));
      await tester.pumpAndSettle();

      await choose(tester, 'subcategory-field', 'pl');
      expect(find.widgetWithText(ListTile, 'Places'), findsOneWidget);
      await tester.tap(find.widgetWithText(ListTile, 'Places'));
      await tester.pumpAndSettle();
      expect(find.text('Religion › Places'), findsOneWidget);
      expect(await app.db.select(app.db.categories).get(), hasLength(2));
    });

    testApp(
      'keyboard 1–5 tag and C focuses the category field',
      (tester, app) async {
        await reviewPack1(tester, app);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
        await tester.pumpAndSettle();
        var abbey = await wordNamed(app, 'abbey');
        expect(abbey.tone, Tone.positive);
        expect(abbey.multipleMeanings, isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
        await tester.pumpAndSettle();
        abbey = await wordNamed(app, 'abbey');
        expect(abbey.tone, isNull);

        await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
        await tester.pumpAndSettle();
        final field = tester.widget<TextField>(
          find.byKey(const ValueKey('category-field')),
        );
        expect(field.focusNode!.hasFocus, isTrue);

        // While typing, shortcuts are ignored: "3" is text, not Neutral.
        await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
        await tester.pumpAndSettle();
        expect((await wordNamed(app, 'abbey')).tone, isNull);
      },
      size: const Size(1280, 800),
    );

    testApp('review controls meet tap-target and label guidelines', (
      tester,
      app,
    ) async {
      await reviewPack1(tester, app);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    }, semantics: true);
  });
}
