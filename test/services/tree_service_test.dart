import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/data/db/database.dart';
import 'package:wordpack/data/repositories/pack_repo.dart';
import 'package:wordpack/data/repositories/word_repo.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/domain/tree.dart';
import 'package:wordpack/services/import_service.dart';
import 'package:wordpack/services/learning_service.dart';
import 'package:wordpack/services/tagging_service.dart';
import 'package:wordpack/services/tree_service.dart';

import '../support/test_db.dart';

void main() {
  late AppDatabase db;
  late TreeService trees;
  late TaggingService tags;
  late String wl;
  late List<Word> pack1;

  TreeNode node(List<TreeNode> roots, String id) => findPath(roots, id).last;
  Future<Word> byTerm(String t) async => (await (db.select(
    db.words,
  )..where((w) => w.term.equals(t))).get()).single;

  setUp(() async {
    db = memoryDb();
    final importer = ImportService(db: db, clock: FixedClock(), ids: SeqIds());
    final report = await importer.preview(
      File('fixtures/sample-columns.csv').readAsBytesSync(),
    );
    wl = await importer.commit(report, name: 'Sample', sourceFilename: 's.csv');
    final packs = await PackRepo(db).forWordlist(wl);
    await (db.update(db.packs)..where((p) => p.id.equals(packs[0].id))).write(
      const PacksCompanion(
        masteryWd: Value(Mastery.mastered),
        masteryDw: Value(Mastery.mastered),
      ),
    );
    pack1 = await WordRepo(db).forPack(packs[0].id);
    trees = TreeService(db);
    tags = TaggingService(db: db, clock: FixedClock(), ids: _Ids('t'));
  });
  tearDown(() => db.close());

  group('R-11 tree', () {
    test('structure and counts for a fresh import', () async {
      final roots = await trees.buildTree();
      final list = roots.single;
      expect(list.name, 'Sample');
      expect(list.count, 60);
      expect(
        [for (final c in list.children) c.kind],
        [
          NodeKind.packs,
          NodeKind.categories,
          NodeKind.tags,
          NodeKind.uncategorised,
        ],
      );
      final packs = node(roots, NodeIds.packs(wl));
      expect(packs.learned, 1);
      expect([for (final p in packs.children) p.packNumber], [1, 2]);
      expect(
        [for (final p in packs.children) p.status],
        [PackStatus.learned, PackStatus.newPack],
      );
      expect(packs.children.first.count, 30);
      expect(node(roots, NodeIds.categories(wl)).count, 0);
      expect(node(roots, NodeIds.uncategorised(wl)).count, 60);
      expect(node(roots, NodeIds.tags(wl)).count, 0);
      expect(node(roots, NodeIds.tag(wl, 'untagged')).count, 60);
    });

    test('categories, (no subcategory) and tag counts', () async {
      await tags.assign(
        pack1[0].id,
        category: 'Religion',
        subcategory: 'Places',
      );
      await tags.assign(
        pack1[1].id,
        category: 'religion',
        subcategory: 'Places',
      );
      await tags.assign(pack1[2].id, category: 'Religion');
      await tags.assign(pack1[3].id, category: 'Emotions');
      await tags.setTone(pack1[0].id, Tone.negative);
      await tags.toggleTrait(pack1[0].id, Trait.counterIntuitive);
      await tags.toggleTrait(pack1[4].id, Trait.multipleMeanings);

      final roots = await trees.buildTree();
      final cats = node(roots, NodeIds.categories(wl));
      expect(cats.count, 4);
      expect([for (final c in cats.children) c.name], ['Emotions', 'Religion']);
      final emotions = cats.children.first;
      expect(emotions.children, isEmpty, reason: 'no subcategories → no nosub');
      final religion = cats.children.last;
      expect(religion.count, 3);
      expect(
        [for (final c in religion.children) (c.kind, c.count)],
        [(NodeKind.subcategory, 2), (NodeKind.noSubcategory, 1)],
      );
      expect(religion.children.first.name, 'Places');
      expect(node(roots, NodeIds.uncategorised(wl)).count, 56);

      int tag(String k) => node(roots, NodeIds.tag(wl, k)).count;
      expect(tag('negative'), 1);
      expect(tag('positive'), 0);
      expect(tag('counterIntuitive'), 1);
      expect(tag('multipleMeanings'), 1);
      expect(tag('untagged'), 58);
      expect(node(roots, NodeIds.tags(wl)).count, 2);
    });

    test('the tree stream updates after tagging and after a pass', () async {
      final updates = <List<TreeNode>>[];
      final sub = trees.watchTree().listen(updates.add);
      await pumpEventQueue();
      expect(node(updates.last, NodeIds.tag(wl, 'positive')).count, 0);

      await tags.setTone(pack1[0].id, Tone.positive);
      await pumpEventQueue();
      expect(node(updates.last, NodeIds.tag(wl, 'positive')).count, 1);

      final pack2 = node(updates.last, NodeIds.packs(wl)).children.last;
      await LearningService(
        db: db,
        clock: FixedClock(),
        ids: _Ids('l'),
      ).open(NodeIds.parse(pack2.id)!.targetId!, Direction.wd);
      await pumpEventQueue();
      expect(
        node(updates.last, pack2.id).status,
        PackStatus.learning,
        reason: 'an open pass makes a New pack Learning',
      );
      await sub.cancel();
    });
  });

  group('R-11 node words and ordering', () {
    Future<List<String>> terms(String nodeId) async => [
      for (final w in await trees.watchWords(nodeId).first) w.term,
    ];

    test('pack and wordlist nodes are in source order', () async {
      final p1 = pack1.first.packId;
      expect(await terms(NodeIds.pack(p1)), [for (final w in pack1) w.term]);
      final all = await terms(NodeIds.wordlist(wl));
      expect(all.first, 'abbey');
      expect(all, hasLength(60));
      expect(await terms(NodeIds.packs(wl)), all);
    });

    test('category, tag and uncategorised nodes are alphabetical', () async {
      // Assign in reverse order; results come back sorted.
      for (final w in pack1.take(3).toList().reversed) {
        await tags.assign(w.id, category: 'Religion', subcategory: 'Places');
        await tags.setTone(w.id, Tone.neutral);
      }
      await tags.assign(pack1[5].id, category: 'Religion');
      final religion = (await byTerm(pack1[0].term)).categoryId!;
      final places = (await byTerm(pack1[0].term)).subcategoryId!;
      final sorted = [for (final w in pack1.take(3)) w.term]..sort();

      expect(await terms(NodeIds.subcategory(wl, places)), sorted);
      expect(
        await terms(NodeIds.category(wl, religion)),
        [...sorted, pack1[5].term]..sort(),
        reason: 'category includes its subcategories',
      );
      expect(await terms(NodeIds.noSubcategory(wl, religion)), [pack1[5].term]);
      expect(await terms(NodeIds.categories(wl)), hasLength(4));
      expect(await terms(NodeIds.tag(wl, 'neutral')), sorted);
      expect(await terms(NodeIds.tags(wl)), sorted);
      final uncat = await terms(NodeIds.uncategorised(wl));
      expect(uncat, hasLength(56));
      expect(uncat, [...uncat]..sort());
    });

    test('every tag key filters', () async {
      await tags.setTone(pack1[0].id, Tone.positive);
      await tags.setTone(pack1[1].id, Tone.negative);
      await tags.toggleTrait(pack1[2].id, Trait.counterIntuitive);
      await tags.toggleTrait(pack1[3].id, Trait.multipleMeanings);
      expect(await terms(NodeIds.tag(wl, 'positive')), [pack1[0].term]);
      expect(await terms(NodeIds.tag(wl, 'negative')), [pack1[1].term]);
      expect(await terms(NodeIds.tag(wl, 'counterIntuitive')), [pack1[2].term]);
      expect(await terms(NodeIds.tag(wl, 'multipleMeanings')), [pack1[3].term]);
      expect(await terms(NodeIds.tag(wl, 'untagged')), hasLength(56));
    });

    test('search matches term or definition, case-insensitively', () async {
      expect(await terms(NodeIds.search('ABB')), ['abbey']);
      expect(await terms(NodeIds.search('monastery')), ['abbey']);
      expect(await terms(NodeIds.search('100%_')), isEmpty);
      expect(await terms('nonsense'), isEmpty);
    });

    test('the learned-pack stream follows mastery', () async {
      final learned = await trees.watchLearnedPackIds().first;
      expect(learned, {pack1.first.packId});
    });
  });
}

class _Ids extends SeqIds {
  _Ids(this.prefix);

  final String prefix;

  @override
  String newId() => '$prefix-${super.newId()}';
}
