import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/data/repositories/pack_repo.dart';
import 'package:wordpack/data/repositories/pass_repo.dart';
import 'package:wordpack/data/repositories/word_repo.dart';
import 'package:wordpack/domain/learning.dart' show PassState;
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/services/import_service.dart';
import 'package:wordpack/services/learning_service.dart';

import '../support/test_db.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late LearningService service;
  late String packId;
  late List<Word> words;

  Future<Pack> pack() async => (await PackRepo(db).get(packId))!;
  Future<PackStatus> status() async {
    final rows = await PackRepo(db).watchRows((await pack()).wordlistId).first;
    return rows.firstWhere((r) => r.pack.id == packId).status(LearnedRule.both);
  }

  /// Runs a pass from its current card to the end, pressing Show on the cards
  /// at [peekAt] (0-based). Returns the final update.
  Future<PassUpdate> finish(Direction d, {Set<int> peekAt = const {}}) async {
    PassState? state = await service.open(packId, d);
    PassUpdate update = PassUpdate(state);
    while (state != null) {
      if (peekAt.contains(state.index)) await service.show(packId, d);
      update = await service.next(packId, d);
      state = update.pass;
    }
    return update;
  }

  setUp(() async {
    db = memoryDb();
    clock = FixedClock();
    service = LearningService(db: db, clock: clock, ids: SeqIds());
    final importer = ImportService(db: db, clock: clock, ids: SeqIds());
    final report = await importer.preview(
      File('fixtures/sample-columns.csv').readAsBytesSync(),
    );
    final listId = await importer.commit(
      report,
      name: '',
      sourceFilename: 'sample-columns.csv',
    );
    packId = (await PackRepo(db).forWordlist(listId)).first.id;
    words = await WordRepo(db).forPack(packId);
    // The importer's ids and the service's ids must not collide.
    service = LearningService(db: db, clock: clock, ids: _PrefixedIds('s'));
  });
  tearDown(() => db.close());

  test('R-6 worked example (rule = both) via the service', () async {
    expect(await status(), PackStatus.newPack);

    // Start WD, Next ×3 → Learning (open pass).
    await service.open(packId, Direction.wd);
    for (var i = 0; i < 3; i++) {
      await service.next(packId, Direction.wd);
    }
    expect(await status(), PackStatus.learning);
    expect((await pack()).masteryWd, Mastery.unseen);
    expect((await pack()).lastDirection, Direction.wd);

    // Show on card 4.
    final shown = await service.show(packId, Direction.wd);
    expect(shown.pass!.peeks, 1);
    expect((await pack()).masteryWd, Mastery.learning);
    final peeked = (await WordRepo(db).forPack(packId))[3];
    expect(peeked.revealCountWd, 1);
    expect(peeked.lastRevealedAt, clock.at);

    // Finish the pass (1 peek).
    var end = await finish(Direction.wd);
    expect(end.pass, isNull);
    expect(end.result!.clean, isFalse);
    expect(end.result!.peekedWordIds, [peeked.id]);
    expect(end.result!.becameLearned, isFalse);
    expect((await pack()).passesWd, 1);
    expect((await pack()).cleanPassesWd, 0);
    expect(await PassRepo(db).get(packId, Direction.wd), isNull);

    // Repeat WD, 0 peeks → WD mastered.
    end = await finish(Direction.wd);
    expect(end.result!.clean, isTrue);
    expect(end.result!.status, PackStatus.learning);
    final p = await pack();
    expect(p.masteryWd, Mastery.mastered);
    expect(p.masteredAtWd, clock.at);
    expect(p.passesWd, 2);
    expect(p.cleanPassesWd, 1);
    expect(
      (await WordRepo(db).forPack(packId)).every((w) => w.masteredWd),
      isTrue,
    );

    // DW with 2 peeks, then DW clean → Learned, exactly once.
    end = await finish(Direction.dw, peekAt: {0, 2});
    expect(end.result!.peekedWordIds, hasLength(2));
    expect((await pack()).masteryDw, Mastery.learning);

    end = await finish(Direction.dw);
    expect(end.result!.becameLearned, isTrue);
    expect(end.result!.status, PackStatus.learned);
    expect((await pack()).learnedAt, clock.at);
    expect(await status(), PackStatus.learned);

    // A later review pass never reports becameLearned again.
    clock.at = clock.at.add(const Duration(days: 1));
    end = await finish(Direction.wd);
    expect(end.result!.becameLearned, isFalse);
    expect((await pack()).learnedAt, DateTime.utc(2026, 9, 24, 10));
  });

  test('R-5 a failure mid-action leaves no partial writes', () async {
    await service.open(packId, Direction.wd);
    final failing = LearningService(
      db: db,
      clock: clock,
      ids: SeqIds(failAfter: 0),
    );
    // Show writes the word and the pack, then fails saving the pass.
    await expectLater(failing.show(packId, Direction.wd), throwsStateError);
    expect((await WordRepo(db).forPack(packId)).first.revealCountWd, 0);
    expect((await pack()).masteryWd, Mastery.unseen);
    final saved = await PassRepo(db).get(packId, Direction.wd);
    expect(saved!.revealed, isEmpty);
  });

  test('pass state survives: open resumes at the same card', () async {
    await service.open(packId, Direction.dw);
    await service.next(packId, Direction.dw);
    await service.show(packId, Direction.dw);
    final resumed = await service.open(packId, Direction.dw);
    expect(resumed.index, 1);
    expect(resumed.currentRevealed, isTrue);
    expect(resumed.passNumber, 1);
  });

  test('previous never adds a reveal; stays on card 1 at the start', () async {
    await service.open(packId, Direction.wd);
    await service.show(packId, Direction.wd);
    await service.next(packId, Direction.wd);
    final back = await service.previous(packId, Direction.wd);
    expect(back.pass!.index, 0);
    expect(back.pass!.currentRevealed, isTrue);
    expect(back.pass!.peeks, 1);
    expect((await WordRepo(db).forPack(packId)).first.revealCountWd, 1);
  });

  test('switchDirection abandons the pass and starts card 1', () async {
    await service.open(packId, Direction.wd);
    await service.show(packId, Direction.wd);
    await service.next(packId, Direction.wd);
    final dw = await service.switchDirection(
      packId,
      from: Direction.wd,
      to: Direction.dw,
    );
    expect(dw.direction, Direction.dw);
    expect(dw.index, 0);
    expect(await PassRepo(db).get(packId, Direction.wd), isNull);
    // The reveal stays recorded.
    expect((await pack()).masteryWd, Mastery.learning);
    expect((await pack()).lastDirection, Direction.dw);
  });

  test('restart drops the pass; pass numbers count completed passes', () async {
    await finish(Direction.wd, peekAt: {1});
    await service.open(packId, Direction.wd);
    await service.next(packId, Direction.wd);
    final again = await service.restart(packId, Direction.wd);
    expect(again.index, 0);
    expect(again.passNumber, 2);
  });

  group('review (pack Learned)', () {
    setUp(() async {
      await finish(Direction.wd);
      await finish(Direction.dw);
    });

    test('peeks are recorded but do not demote by default', () async {
      final end = await finish(Direction.wd, peekAt: {0});
      expect(end.result!.clean, isFalse);
      expect(end.result!.status, PackStatus.learned);
      expect((await pack()).masteryWd, Mastery.mastered);
      final first = (await WordRepo(db).forPack(packId)).first;
      expect(first.revealCountWd, 1);
      expect(first.masteredWd, isTrue);
    });

    test('with demoteOnReveal the pack and the word are demoted', () async {
      await db
          .update(db.appSettings)
          .write(const AppSettingsCompanion(demoteOnReveal: Value(true)));
      await service.open(packId, Direction.wd);
      await service.show(packId, Direction.wd);
      expect((await pack()).masteryWd, Mastery.learning);
      expect(await status(), PackStatus.learning);
      final first = (await WordRepo(db).forPack(packId)).first;
      expect(first.masteredWd, isFalse);
      expect(first.masteredDw, isTrue);
    });
  });

  test('errors: unknown pack, no open pass', () async {
    await expectLater(
      service.open('nope', Direction.wd),
      throwsA(isA<PackNotFoundException>()),
    );
    await expectLater(
      service.next(packId, Direction.dw),
      throwsA(isA<NoOpenPassException>()),
    );
    expect(words, hasLength(30));
  });
}

class _PrefixedIds extends SeqIds {
  _PrefixedIds(this.prefix);

  final String prefix;

  @override
  String newId() => '$prefix-${super.newId()}';
}
