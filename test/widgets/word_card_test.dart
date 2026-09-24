import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/l10n/app_localizations.dart';
import 'package:wordpack/ui/card/word_card.dart';
import 'package:wordpack/ui/theme/app_theme.dart';

Word word({
  String term = 'absurd',
  String? pos = 'adjective',
  String? posRaw = 'j',
  String definition = 'inconsistent with reason or logic or common sense',
}) => Word(
  id: 'w1',
  wordlistId: 'l1',
  position: 0,
  term: term,
  pos: pos,
  posRaw: posRaw,
  definition: definition,
  packId: 'p1',
  counterIntuitive: false,
  multipleMeanings: false,
  masteredWd: false,
  masteredDw: false,
  revealCountWd: 0,
  revealCountDw: 0,
  updatedAt: DateTime.utc(2026),
);

/// The card plus a button below it, to check nothing moves on reveal.
Widget host(Word w, Direction d, {required bool revealed}) => MaterialApp(
  theme: AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Column(
      children: [
        WordCard(word: w, direction: d, revealed: revealed),
        FilledButton(onPressed: () {}, child: const Text('Next')),
      ],
    ),
  ),
);

double opacityOfAnswer(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(find.byKey(const ValueKey('answer')))
    .opacity;

void main() {
  testWidgets('W-1 WD shows the term; the definition is hidden until Show', (
    tester,
  ) async {
    await tester.pumpWidget(host(word(), Direction.wd, revealed: false));
    expect(find.text('absurd'), findsOneWidget);
    expect(opacityOfAnswer(tester), 0);
    expect(
      find.bySemanticsLabel(RegExp('inconsistent with reason')),
      findsNothing,
    );
    final before = tester.getRect(find.text('Next'));

    await tester.pumpWidget(host(word(), Direction.wd, revealed: true));
    await tester.pumpAndSettle();
    expect(opacityOfAnswer(tester), 1);
    expect(tester.getRect(find.text('Next')), before, reason: 'no movement');
  });

  testWidgets('W-1 DW shows the definition; the word is the answer', (
    tester,
  ) async {
    await tester.pumpWidget(host(word(), Direction.dw, revealed: false));
    final defTop = tester.getTopLeft(
      find.textContaining('inconsistent with reason'),
    );
    final termTop = tester.getTopLeft(find.text('absurd'));
    expect(defTop.dy, lessThan(termTop.dy), reason: 'definition is the prompt');
    expect(opacityOfAnswer(tester), 0);
    final before = tester.getRect(find.text('Next'));

    await tester.pumpWidget(host(word(), Direction.dw, revealed: true));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Next')), before);
  });

  testWidgets('W-1 a 204-character prompt is start-aligned and fits', (
    tester,
  ) async {
    const hybrid =
        '(genetics) an organism that is the offspring of genetically '
        'dissimilar parents or stock; especially offspring produced by '
        'breeding plants or animals of different varieties or breeds or '
        'species';
    await tester.pumpWidget(
      host(
        word(term: 'hybrid', definition: hybrid),
        Direction.dw,
        revealed: false,
      ),
    );
    final text = tester.widget<Text>(find.text(hybrid));
    expect(text.textAlign, TextAlign.start);
    expect(tester.takeException(), isNull);
  });

  testWidgets('W-2 POS chip "adj." is read as "adjective"', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(word(), Direction.wd, revealed: false));
    expect(find.text('adj.'), findsOneWidget);
    // The card is announced as one item: the word, then the full POS name.
    expect(
      find.bySemanticsLabel(RegExp(r'^absurd\s+adjective$')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp(r'adj\.')), findsNothing);
    handle.dispose();
  });

  testWidgets('no POS: no chip', (tester) async {
    await tester.pumpWidget(
      host(word(pos: null, posRaw: null), Direction.wd, revealed: false),
    );
    expect(find.text('adj.'), findsNothing);
  });
}
