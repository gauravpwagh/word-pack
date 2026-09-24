import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/l10n/app_localizations.dart';
import 'package:wordpack/ui/card/dashed_border_painter.dart';
import 'package:wordpack/ui/card/word_card.dart';
import 'package:wordpack/ui/tagging/category_row.dart';
import 'package:wordpack/ui/tagging/quick_tag_bar.dart';
import 'package:wordpack/ui/theme/app_theme.dart';
import 'package:wordpack/ui/theme/wp_colors.dart';

import 'word_card_test.dart' show word;

Widget wrap(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: child,
    ),
  ),
);

Word tagged({
  Tone? tone,
  bool counter = false,
  bool multi = false,
  String? categoryId,
  String? subcategoryId,
}) => word().copyWith(
  tone: Value(tone),
  counterIntuitive: counter,
  multipleMeanings: multi,
  categoryId: Value(categoryId),
  subcategoryId: Value(subcategoryId),
);

Category cat(String id, String name, [String? parent]) => Category(
  id: id,
  name: name,
  key: name.toLowerCase(),
  parentId: parent,
  createdAt: DateTime.utc(2026),
);

bool chipSelected(WidgetTester tester, String key) =>
    tester.widget<FilterChip>(find.byKey(ValueKey(key))).selected;

void main() {
  group('W-4 QuickTagBar', () {
    testWidgets('tone is single-select with clear; traits independent', (
      tester,
    ) async {
      Tone? toneOut = Tone.neutral; // sentinel
      Trait? traitOut;
      Future<void> pump(Word w) => tester.pumpWidget(
        wrap(
          QuickTagBar(
            word: w,
            onTone: (t) => toneOut = t,
            onTrait: (t) => traitOut = t,
          ),
        ),
      );

      await pump(tagged());
      expect(find.text('Positive'), findsOneWidget);
      expect(find.text('Multiple meanings'), findsOneWidget);
      await tester.tap(find.text('Negative'));
      expect(toneOut, Tone.negative);

      await pump(tagged(tone: Tone.negative));
      expect(chipSelected(tester, 'tone-negative'), isTrue);
      expect(chipSelected(tester, 'tone-positive'), isFalse);
      await tester.tap(find.text('Negative'));
      expect(toneOut, isNull, reason: 'tapping the active tone clears it');
      await tester.tap(find.text('Positive'));
      expect(toneOut, Tone.positive, reason: 'another tone replaces it');

      await tester.tap(find.text('Counter-intuitive'));
      expect(traitOut, Trait.counterIntuitive);
      await pump(tagged(tone: Tone.negative, counter: true));
      expect(chipSelected(tester, 'trait-counterIntuitive'), isTrue);
      expect(chipSelected(tester, 'trait-multipleMeanings'), isFalse);
      expect(chipSelected(tester, 'tone-negative'), isTrue);
    });

    testWidgets('selected state and labels reach screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(
          QuickTagBar(
            word: tagged(tone: Tone.positive, multi: true),
            onTone: (_) {},
            onTrait: (_) {},
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byKey(const ValueKey('tone-positive'))),
        matchesSemantics(
          label: 'Positive',
          isSelected: true,
          hasSelectedState: true,
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  });

  group('W-5 tag visuals', () {
    for (final (themeName, theme, wp) in [
      ('light', AppTheme.light(), WpColors.light),
      ('dark', AppTheme.dark(), WpColors.dark),
    ]) {
      final combos = <String, (Word, Color?, Color?, bool, List<String>)>{
        // name: word, edge colour, tint, dashed, badge labels
        'no tags': (tagged(), null, null, false, []),
        'positive': (
          tagged(tone: Tone.positive),
          wp.positive,
          wp.positiveTint,
          false,
          ['Positive'],
        ),
        'negative': (
          tagged(tone: Tone.negative),
          wp.negative,
          wp.negativeTint,
          false,
          ['Negative'],
        ),
        'neutral (edge, no tint)': (
          tagged(tone: Tone.neutral),
          wp.neutral,
          null,
          false,
          ['Neutral'],
        ),
        'counter-intuitive only': (
          tagged(counter: true),
          null,
          null,
          true,
          ['Counter-intuitive'],
        ),
        'multiple meanings only': (
          tagged(multi: true),
          null,
          null,
          false,
          ['Multiple meanings'],
        ),
        'negative + counter-intuitive': (
          tagged(tone: Tone.negative, counter: true),
          wp.negative,
          wp.negativeTint,
          true,
          ['Negative', 'Counter-intuitive'],
        ),
        'positive + multiple meanings': (
          tagged(tone: Tone.positive, multi: true),
          wp.positive,
          wp.positiveTint,
          false,
          ['Positive', 'Multiple meanings'],
        ),
        'all traits + a tone': (
          tagged(tone: Tone.neutral, counter: true, multi: true),
          wp.neutral,
          null,
          true,
          ['Neutral', 'Counter-intuitive', 'Multiple meanings'],
        ),
      };

      for (final MapEntry(key: name, value: (w, edge, tint, dashed, badges))
          in combos.entries) {
        testWidgets('$themeName: $name', (tester) async {
          final handle = tester.ensureSemantics();
          await tester.pumpWidget(
            wrap(
              WordCard(word: w, direction: Direction.wd, revealed: false),
              theme: theme,
            ),
          );
          await tester.pumpAndSettle();

          final edgeFinder = find.byKey(const ValueKey('tone-edge'));
          if (edge == null) {
            expect(edgeFinder, findsNothing);
          } else {
            final box = tester.widget<ColoredBox>(
              find.descendant(
                of: edgeFinder,
                matching: find.byType(ColoredBox),
              ),
            );
            expect(box.color, edge);
            expect(tester.getSize(edgeFinder).width, 6);
          }

          final surface = tester.widget<AnimatedContainer>(
            find.byKey(const ValueKey('card-surface')),
          );
          final decoration = surface.decoration! as BoxDecoration;
          expect(decoration.color, tint ?? theme.colorScheme.surface);
          expect(
            (decoration.border! as Border).top.color,
            dashed ? Colors.transparent : theme.colorScheme.outlineVariant,
          );

          final painters = tester
              .widgetList<CustomPaint>(find.byType(CustomPaint))
              .map((p) => p.foregroundPainter)
              .whereType<DashedBorderPainter>();
          expect(painters.length, dashed ? 1 : 0);
          if (dashed) expect(painters.single.color, wp.counterOutline);

          // The card is read as one item: word, POS, then each badge.
          final label = tester
              .getSemantics(find.byType(WordCard))
              .label
              .replaceAll('\n', ' ');
          expect(
            label,
            [
              'absurd',
              'adjective',
              if (badges.isNotEmpty) badges.join(', '),
            ].join(' '),
          );
          handle.dispose();
        });
      }
    }

    testWidgets('tagging never moves the card content', (tester) async {
      await tester.pumpWidget(
        wrap(
          WordCard(word: tagged(), direction: Direction.wd, revealed: false),
        ),
      );
      final before = tester.getRect(find.text('absurd'));
      await tester.pumpWidget(
        wrap(
          WordCard(
            word: tagged(tone: Tone.negative, counter: true, multi: true),
            direction: Direction.wd,
            revealed: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text('absurd')), before);
    });
  });

  group('W-6 CategoryRow', () {
    final categories = [
      cat('c1', 'Emotions'),
      cat('c2', 'Religion'),
      cat('s1', 'Anger', 'c1'),
      cat('s2', 'Places', 'c2'),
    ];

    Future<List<(String?, String?)>> pump(WidgetTester tester, Word w) async {
      final calls = <(String?, String?)>[];
      await tester.pumpWidget(
        wrap(
          CategoryRow(
            word: w,
            categories: categories,
            onAssign: (c, s) => calls.add((c, s)),
          ),
        ),
      );
      return calls;
    }

    TextField field(WidgetTester tester, String key) =>
        tester.widget<TextField>(find.byKey(ValueKey(key)));

    testWidgets('filters case-insensitively; Create only without exact match', (
      tester,
    ) async {
      final calls = await pump(tester, tagged());
      await tester.tap(find.byKey(const ValueKey('category-field')));
      await tester.enterText(
        find.byKey(const ValueKey('category-field')),
        'EMO',
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Emotions'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Religion'), findsNothing);
      expect(find.text('Create “EMO”'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('category-field')),
        'emotions',
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Create'), findsNothing);

      await tester.tap(find.widgetWithText(ListTile, 'Emotions'));
      await tester.pumpAndSettle();
      expect(calls, [('Emotions', null)]);
    });

    testWidgets('Create "Annoyance" saves the new name', (tester) async {
      final calls = await pump(tester, tagged());
      await tester.enterText(
        find.byKey(const ValueKey('category-field')),
        '  Annoyance ',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create “Annoyance”'));
      await tester.pumpAndSettle();
      expect(calls, [('Annoyance', null)]);
    });

    testWidgets('subcategory is disabled until a category is chosen', (
      tester,
    ) async {
      await pump(tester, tagged());
      expect(field(tester, 'subcategory-field').enabled, isFalse);

      final calls = await pump(tester, tagged(categoryId: 'c1'));
      expect(field(tester, 'subcategory-field').enabled, isTrue);
      expect(field(tester, 'category-field').controller!.text, 'Emotions');

      // Only Emotions' subcategories are offered.
      await tester.tap(find.byKey(const ValueKey('subcategory-field')));
      await tester.enterText(
        find.byKey(const ValueKey('subcategory-field')),
        'a',
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Anger'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Places'), findsNothing);
      await tester.tap(find.widgetWithText(ListTile, 'Anger'));
      await tester.pumpAndSettle();
      expect(calls, [('Emotions', 'Anger')]);
    });

    testWidgets('clear buttons and Enter', (tester) async {
      final calls = await pump(
        tester,
        tagged(categoryId: 'c1', subcategoryId: 's1'),
      );
      await tester.tap(find.byTooltip('Clear subcategory'));
      await tester.tap(find.byTooltip('Clear category'));
      expect(calls, [('Emotions', null), (null, null)]);

      calls.clear();
      await tester.enterText(
        find.byKey(const ValueKey('category-field')),
        'religion',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(calls, [('Religion', null)], reason: 'existing spelling kept');
    });
  });
}
