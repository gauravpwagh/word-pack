import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wordpack/app/app.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/data/repositories/pack_repo.dart';
import 'package:wordpack/data/repositories/word_repo.dart';
import 'package:wordpack/data/system.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/providers/providers.dart';
import 'package:wordpack/services/file_picking.dart';
import 'package:wordpack/services/tagging_service.dart';

import 'fixture_data.g.dart';

/// Hands out the given fixture on every pick (I-1: "inject the file through a
/// fake picker").
class FixturePicker implements ImportFilePicker {
  FixturePicker(this.name);

  final String name;

  @override
  Future<PickedFile?> pick() async =>
      PickedFile(name: name, bytes: Uint8List.fromList(fixtureBytes[name]!));
}

Future<void> pumpApp(
  WidgetTester tester,
  AppDatabase db,
  String fixture,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        importFilePickerProvider.overrideWithValue(FixturePicker(fixture)),
      ],
      child: const WordPackApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('I-1 import definitions.txt → 998 words, 34 packs, all New', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await pumpApp(tester, db, 'definitions.txt');

    expect(find.text('Import CSV'), findsOneWidget);
    await tapText(tester, 'Import CSV');

    expect(find.text('998 words ready'), findsOneWidget);
    expect(
      find.text('noun 501 · adj. 336 · verb 149 · adv. 12'),
      findsOneWidget,
    );
    expect(find.text('34 packs of 30 (last pack 8)'), findsOneWidget);

    await tapText(tester, 'Import 998 words');

    expect(find.text('0 of 34 packs learned'), findsOneWidget);
    expect(find.text('Continue · Pack 1 · Word → Definition'), findsOneWidget);
    final lists = await db.select(db.wordlists).get();
    final rows = await PackRepo(db).watchRows(lists.single.id).first;
    expect(rows, hasLength(34));
    expect(rows.last.wordCount, 8);
    expect(
      rows.every((r) => r.status(LearnedRule.both) == PackStatus.newPack),
      isTrue,
    );
    final words = await WordRepo(db).forWordlist(lists.single.id);
    expect(words.firstWhere((w) => w.term == 'wherever').pos, 'adverb');

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('M2 data survives closing and reopening the database', (
    tester,
  ) async {
    var db = AppDatabase.open();
    // Start from an empty database file.
    await db.delete(db.wordlists).go();
    await pumpApp(tester, db, 'edge-cases.txt');
    await tapText(tester, 'Import CSV');
    await tapText(tester, 'Import 9 words');
    expect(find.text('0 of 1 pack learned'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await db.close();

    db = AppDatabase.open();
    addTearDown(db.close);
    await pumpApp(tester, db, 'edge-cases.txt');
    expect(find.text('edge-cases'), findsOneWidget);
    expect(find.text('0 of 1 pack learned'), findsOneWidget);
    expect(await WordRepo(db).countAll(), 9);
    await tester.pumpWidget(const SizedBox());
  });

  group('M3 learning', () {
    Future<void> next(WidgetTester tester, [int times = 1]) async {
      for (var i = 0; i < times; i++) {
        await tester.tap(find.byKey(const ValueKey('next')));
        await tester.pumpAndSettle();
      }
    }

    Future<void> show(WidgetTester tester) async {
      await tester.tap(find.byKey(const ValueKey('show')));
      await tester.pumpAndSettle();
    }

    Future<AppDatabase> importDefinitions(WidgetTester tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await pumpApp(tester, db, 'definitions.txt');
      await tapText(tester, 'Import CSV');
      await tapText(tester, 'Import 998 words');
      return db;
    }

    testWidgets('I-2 + I-3 pack 1: clean WD, DW with a peek, then learned', (
      tester,
    ) async {
      await importDefinitions(tester);
      await tapText(tester, 'Continue · Pack 1 · Word → Definition');

      // I-2: Next ×30 → clean pass; WD mastered, pack still Learning.
      await next(tester, 30);
      expect(
        find.text('Clean pass — Pack 1 · Word → Definition mastered.'),
        findsOneWidget,
      );

      // I-3: DW, Show on card 5, finish → 1 peek.
      await tapText(tester, 'Start Definition → Word');
      await next(tester, 4);
      await show(tester);
      expect(find.text('Peeks this pass: 1'), findsOneWidget);
      await next(tester, 26);
      expect(find.textContaining('Pass finished with 1 peek'), findsOneWidget);

      // Repeat with Next only → learned; no categorise prompt.
      await tapText(tester, 'Repeat pack');
      await next(tester, 30);
      expect(find.text('Pack 1 learned!'), findsOneWidget);
      expect(find.textContaining('ategor'), findsNothing);

      await tapText(tester, 'Back to wordlist');
      expect(find.text('1 of 34 packs learned'), findsOneWidget);
      expect(find.text('Learned'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('I-5 switch direction mid-pass → confirm → card 1 in DW', (
      tester,
    ) async {
      await importDefinitions(tester);
      await tapText(tester, 'Continue · Pack 1 · Word → Definition');
      await next(tester, 5);
      await tester.tap(find.text('Def → Word'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Switch');
      expect(find.text('1 / 30'), findsOneWidget);
      expect(find.text('a monastery ruled by an abbot'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('I-4 restart mid-pass at card 12 with one peek → resume', (
      tester,
    ) async {
      var db = AppDatabase.open();
      await db.delete(db.wordlists).go();
      await pumpApp(tester, db, 'definitions.txt');
      await tapText(tester, 'Import CSV');
      await tapText(tester, 'Import 998 words');
      await tapText(tester, 'Continue · Pack 1 · Word → Definition');
      await next(tester, 4);
      await show(tester);
      await next(tester, 7);
      expect(find.text('12 / 30'), findsOneWidget);

      // "Kill" the app: tear down the widget tree and close the database.
      await tester.pumpWidget(const SizedBox());
      await db.close();

      db = AppDatabase.open();
      addTearDown(() async {
        await db.delete(db.wordlists).go();
        await db.close();
      });
      await pumpApp(tester, db, 'definitions.txt');
      const banner = 'Resume Pack 1 · Word → Definition · card 12 / 30';
      expect(find.text(banner), findsOneWidget);
      await tapText(tester, banner);
      expect(find.text('12 / 30'), findsOneWidget);
      expect(find.text('Peeks this pass: 1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('M4 review', () {
    Future<AppDatabase> reviewPack1(WidgetTester tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await pumpApp(tester, db, 'definitions.txt');
      await tapText(tester, 'Import CSV');
      await tapText(tester, 'Import 998 words');
      await (db.update(db.packs)..where((p) => p.number.equals(1))).write(
        const PacksCompanion(
          masteryWd: Value(Mastery.mastered),
          masteryDw: Value(Mastery.mastered),
        ),
      );
      await tester.pumpAndSettle();
      await tapText(tester, 'Pack 1');
      return db;
    }

    Future<void> next(WidgetTester tester, int times) async {
      for (var i = 0; i < times; i++) {
        await tester.tap(find.byKey(const ValueKey('next')));
        await tester.pumpAndSettle();
      }
    }

    Future<Word> word(AppDatabase db, String term) async => (await (db.select(
      db.words,
    )..where((w) => w.term.equals(term))).get()).single;

    testWidgets('I-6 learning pack 2: no tag buttons or category row', (
      tester,
    ) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await pumpApp(tester, db, 'definitions.txt');
      await tapText(tester, 'Import CSV');
      await tapText(tester, 'Import 998 words');
      await tapText(tester, 'Pack 2');
      expect(find.text('Positive'), findsNothing);
      expect(find.text('Category'), findsNothing);
      expect(find.text('Review'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('I-7 accuse: Negative + Counter-intuitive, Negative off', (
      tester,
    ) async {
      final db = await reviewPack1(tester);
      await next(tester, 21);
      expect(find.text('accuse'), findsOneWidget);
      await tapText(tester, 'Negative');
      await tapText(tester, 'Counter-intuitive');
      expect(find.byKey(const ValueKey('tone-edge')), findsOneWidget);
      expect(find.byTooltip('Counter-intuitive'), findsOneWidget);

      await tapText(tester, 'Negative');
      expect(find.byKey(const ValueKey('tone-edge')), findsNothing);
      expect(find.byTooltip('Counter-intuitive'), findsOneWidget);
      final accuse = await word(db, 'accuse');
      expect(accuse.tone, isNull);
      expect(accuse.counterIntuitive, isTrue);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('I-8 abbey → Religion › Places; acclaim suggests both', (
      tester,
    ) async {
      final db = await reviewPack1(tester);
      Future<void> type(String key, String text) async {
        final field = find.byKey(ValueKey(key));
        await tester.ensureVisible(field);
        await tester.tap(field);
        await tester.pumpAndSettle();
        await tester.enterText(field, text);
        await tester.pumpAndSettle();
      }

      await type('category-field', 'Religion');
      await tapText(tester, 'Create “Religion”');
      await type('subcategory-field', 'Places');
      await tapText(tester, 'Create “Places”');
      expect(find.text('Religion › Places'), findsOneWidget);

      await next(tester, 14);
      expect(find.text('acclaim'), findsOneWidget);
      await type('category-field', 'rel');
      await tester.tap(find.widgetWithText(ListTile, 'Religion'));
      await tester.pumpAndSettle();
      await type('subcategory-field', 'pla');
      await tester.tap(find.widgetWithText(ListTile, 'Places'));
      await tester.pumpAndSettle();
      expect(find.text('Religion › Places'), findsOneWidget);
      expect(await db.select(db.categories).get(), hasLength(2));
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('M5 explorer', () {
    /// definitions.txt with pack 1 Learned; abbey and acclaim filed under
    /// Religion › Places.
    Future<AppDatabase> prepare(WidgetTester tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await pumpApp(tester, db, 'definitions.txt');
      await tapText(tester, 'Import CSV');
      await tapText(tester, 'Import 998 words');
      await (db.update(db.packs)..where((p) => p.number.equals(1))).write(
        const PacksCompanion(
          masteryWd: Value(Mastery.mastered),
          masteryDw: Value(Mastery.mastered),
        ),
      );
      final tags = TaggingService(
        db: db,
        clock: const SystemClock(),
        ids: UuidIdGenerator(),
      );
      for (final term in ['abbey', 'acclaim']) {
        final w = await (db.select(
          db.words,
        )..where((x) => x.term.equals(term))).getSingle();
        await tags.assign(w.id, category: 'Religion', subcategory: 'Places');
      }
      await tester.pumpAndSettle();
      return db;
    }

    Future<void> expand(WidgetTester tester, String title) async {
      await tester.tap(find.byTooltip('Expand $title'));
      await tester.pumpAndSettle();
    }

    testWidgets('I-9 Religion › Places → 1 / 2, swipe → 2 / 2, reveal', (
      tester,
    ) async {
      final db = await prepare(tester);
      final before = [
        for (final p in await db.select(db.packs).get())
          (p.masteryWd, p.masteryDw),
      ];
      await tester.tap(find.byTooltip('Open word tree'));
      await tester.pumpAndSettle();
      await expand(tester, 'definitions');
      await expand(tester, 'Categories');
      await expand(tester, 'Religion');
      await tapText(tester, 'Places');
      expect(find.text('1 / 2'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2'), findsOneWidget);
      await tester.tap(find.text('acclaim'));
      await tester.pumpAndSettle();
      expect(find.text('enthusiastic approval'), findsOneWidget);

      final after = [
        for (final p in await db.select(db.packs).get())
          (p.masteryWd, p.masteryDw),
      ];
      expect(after, before, reason: 'browsing changes no status');
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('I-10 phone 360×780: drawer tree, swipe, 2-row tags, 48 dp', (
      tester,
    ) async {
      final dpr = tester.view.devicePixelRatio;
      tester.view.physicalSize = Size(360 * dpr, 780 * dpr);
      addTearDown(tester.view.resetPhysicalSize);
      final handle = tester.ensureSemantics();
      await prepare(tester);

      await tester.tap(find.byTooltip('Open word tree'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);
      await expand(tester, 'definitions');
      await expand(tester, 'Packs');
      await tester.tap(
        find.descendant(of: find.byType(Drawer), matching: find.text('Pack 1')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing, reason: 'drawer closes');
      expect(find.text('1 / 30'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('2 / 30'), findsOneWidget);

      // Tone buttons on one row, traits on the next.
      final positive = tester.getRect(
        find.text('Positive').hitTestable().first,
      );
      final counter = tester.getRect(
        find.text('Counter-intuitive').hitTestable().first,
      );
      expect(counter.top, greaterThan(positive.bottom));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
      await tester.pumpWidget(const SizedBox());
    });
  });

  testWidgets('I-11 pack size 20 → dialog counts → rebuild → pack 1 learned', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await pumpApp(tester, db, 'definitions.txt');
    await tapText(tester, 'Import CSV');
    await tapText(tester, 'Import 998 words');
    // Pack 1 learned: its words and the pack mastered in both directions.
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
    expect(find.text('1 of 34 packs learned'), findsOneWidget);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tapText(tester, 'Pack size');
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byTooltip('−'));
      await tester.pump();
    }
    await tapText(tester, 'Save');
    expect(find.text('Change pack size to 20?'), findsOneWidget);
    expect(find.textContaining('definitions: 34 → 50 packs'), findsOneWidget);
    await tapText(tester, 'Rebuild packs');

    await tester.tap(find.text('Learn').last);
    await tester.pumpAndSettle();
    expect(find.text('1 of 50 packs learned'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
