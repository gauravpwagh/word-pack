import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/ui/shell/tree_panel.dart';
import 'package:wordpack/ui/theme/wp_tokens.dart';

import '../support/app.dart';

void main() {
  group('M0 adaptive shell (UI_UX §1)', () {
    testApp('phone 360×780: bottom bar with 3 sections, tree in drawer', (
      tester,
      app,
    ) async {
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationDestination), findsNWidgets(3));
      expect(find.byType(TreePanel), findsNothing);

      await tester.tap(find.byTooltip('Open word tree'));
      await tester.pumpAndSettle();
      expect(find.byType(TreePanel), findsOneWidget);
    });

    testApp('phone: bottom bar navigates to Settings', (tester, app) async {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pack size'), findsOneWidget);
    });

    testApp('700 wide: rail, tree still in a drawer', (tester, app) async {
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(TreePanel), findsNothing);
      expect(find.byTooltip('Open word tree'), findsOneWidget);
    }, size: const Size(700, 900));

    testApp('desktop 1280×800: rail + permanent tree panel', (
      tester,
      app,
    ) async {
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(TreePanel), findsOneWidget);
      expect(find.byTooltip('Open word tree'), findsNothing);
      expect(
        tester.getSize(find.byType(TreePanel)).width,
        WpTreePanel.defaultWidth,
      );
    }, size: const Size(1280, 800));

    testApp('desktop: tree panel collapses and reopens', (tester, app) async {
      await tester.tap(find.byTooltip('Hide word tree'));
      await tester.pumpAndSettle();
      expect(find.byType(TreePanel), findsNothing);

      await tester.tap(find.byTooltip('Show word tree'));
      await tester.pumpAndSettle();
      expect(find.byType(TreePanel), findsOneWidget);
    }, size: const Size(1280, 800));

    testApp('welcome screen meets tap-target and label guidelines', (
      tester,
      app,
    ) async {
      expect(find.text('Import CSV'), findsOneWidget);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    }, semantics: true);
  });
}
