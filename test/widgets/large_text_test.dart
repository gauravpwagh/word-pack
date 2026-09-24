import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/domain/models.dart';

import '../support/app.dart';

/// Layouts must survive 200 % text (docs/REQUIREMENTS.md §8): every main
/// screen at text scale 2.0 on a 360 × 780 phone, with no overflow errors.
/// Scrolls the lazily built page until [text] exists, then taps it.
Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
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
  await tester.tap(finder.last);
  await tester.pumpAndSettle();
}

void expectNoOverflow(WidgetTester tester, String where) {
  final e = tester.takeException();
  expect(e, isNull, reason: '$where: $e');
}

void main() {
  testApp(
    '200 % text: welcome, import, home, learn, review, explore, settings',
    (tester, app) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      expectNoOverflow(tester, 'welcome');

      app.picker.addFixture('definitions.txt');
      await tapText(tester, 'Import CSV');
      expectNoOverflow(tester, 'import preview');
      await tapText(tester, 'Import 998 words');
      expectNoOverflow(tester, 'wordlist home');

      await (app.db.update(
        app.db.packs,
      )..where((p) => p.number.equals(1))).write(
        const PacksCompanion(
          masteryWd: Value(Mastery.mastered),
          masteryDw: Value(Mastery.mastered),
        ),
      );
      await tester.pumpAndSettle();
      await tapText(tester, 'Pack 2');
      expectNoOverflow(tester, 'learn');
      await tester.tap(find.byKey(const ValueKey('show')));
      await tester.pumpAndSettle();
      expectNoOverflow(tester, 'learn after Show');

      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      await tapText(tester, 'Pack 1');
      expectNoOverflow(tester, 'review');
      await tapText(tester, 'Negative');
      await tapText(tester, 'Counter-intuitive');
      expectNoOverflow(tester, 'review, tagged');

      await tester.tap(find.text('Explore').last);
      await tester.pumpAndSettle();
      expectNoOverflow(tester, 'explore (nothing selected)');
      await tester.tap(find.byTooltip('Open word tree').first);
      await tester.pumpAndSettle();
      expectNoOverflow(tester, 'tree drawer');
      await tester.tap(find.byTooltip('Expand definitions'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Tags');
      expectNoOverflow(tester, 'explorer');
      await tester.tap(find.byTooltip('List'));
      await tester.pumpAndSettle();
      expectNoOverflow(tester, 'explorer list');

      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      expectNoOverflow(tester, 'settings');
    },
  );
}
