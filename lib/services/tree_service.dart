import 'package:drift/drift.dart';

import '../data/db/database.dart';
import '../domain/learning.dart';
import '../domain/models.dart';
import '../domain/tree.dart';

/// Builds the explorer tree and the word lists behind its nodes, as live
/// streams: they update after tagging, categorising or finishing a pass
/// (`docs/UI_UX.md` §8, EXP-2 … EXP-8). Browsing never changes learning
/// status (EXP-4).
class TreeService {
  TreeService(this._db);

  final AppDatabase _db;

  Set<ResultSetImplementation<dynamic, dynamic>> get _tables => {
    _db.wordlists,
    _db.words,
    _db.packs,
    _db.categories,
    _db.passSessions,
    _db.appSettings,
  };

  /// The whole tree, rebuilt whenever one of its tables changes.
  Stream<List<TreeNode>> watchTree() => _db
      .customSelect('SELECT 1', readsFrom: _tables)
      .watch()
      .asyncMap((_) => buildTree());

  Future<List<TreeNode>> buildTree() async {
    final rule = (await (_db.select(
      _db.appSettings,
    )..where((s) => s.id.equals(1))).getSingle()).learnedRule;
    final lists = await (_db.select(
      _db.wordlists,
    )..orderBy([(w) => OrderingTerm.desc(w.importedAt)])).get();
    final categories = {
      for (final c in await _db.select(_db.categories).get()) c.id: c,
    };

    final packRows = await _db.customSelect('''
      SELECT p.id, p.wordlist_id, p.number, p.mastery_wd, p.mastery_dw,
        (SELECT COUNT(*) FROM words w WHERE w.pack_id = p.id) AS words,
        (SELECT COUNT(*) FROM pass_sessions s WHERE s.pack_id = p.id) AS open
      FROM packs p ORDER BY p.number
      ''').get();

    final totals = {
      for (final r in await _db.customSelect('''
        SELECT wordlist_id,
          COUNT(*) AS total,
          SUM(category_id IS NULL) AS uncat,
          SUM(tone = 'positive') AS positive,
          SUM(tone = 'negative') AS negative,
          SUM(tone = 'neutral') AS neutral,
          SUM(counter_intuitive) AS counterIntuitive,
          SUM(multiple_meanings) AS multipleMeanings,
          SUM(tone IS NULL AND counter_intuitive = 0
              AND multiple_meanings = 0) AS untagged
        FROM words GROUP BY wordlist_id
        ''').get())
        r.read<String>('wordlist_id'): r,
    };

    final catRows = await _db.customSelect('''
      SELECT wordlist_id, category_id, subcategory_id, COUNT(*) AS n
      FROM words WHERE category_id IS NOT NULL
      GROUP BY wordlist_id, category_id, subcategory_id
      ''').get();

    return [
      for (final list in lists)
        _wordlistNode(
          list,
          rule,
          packRows.where((r) => r.read<String>('wordlist_id') == list.id),
          totals[list.id],
          catRows.where((r) => r.read<String>('wordlist_id') == list.id),
          categories,
        ),
    ];
  }

  TreeNode _wordlistNode(
    Wordlist list,
    LearnedRule rule,
    Iterable<QueryRow> packRows,
    QueryRow? totals,
    Iterable<QueryRow> catRows,
    Map<String, Category> categories,
  ) {
    final wl = list.id;
    int total(String column) => totals?.read<int?>(column) ?? 0;

    final packs = [
      for (final r in packRows)
        TreeNode(
          id: NodeIds.pack(r.read<String>('id')),
          kind: NodeKind.pack,
          count: r.read<int>('words'),
          packNumber: r.read<int>('number'),
          status: packStatus(
            Mastery.values.byName(r.read<String>('mastery_wd')),
            Mastery.values.byName(r.read<String>('mastery_dw')),
            rule,
            hasOpenPass: r.read<int>('open') > 0,
          ),
        ),
    ];

    // category id → (subcategory id or null) → words
    final byCat = <String, Map<String?, int>>{};
    for (final r in catRows) {
      final c = r.read<String>('category_id');
      final s = r.readNullable<String>('subcategory_id');
      (byCat[c] ??= {})[s] = r.read<int>('n');
    }
    String sortKey(String id) => categories[id]?.key ?? id;
    final categoryNodes = [
      for (final c
          in byCat.keys.toList()
            ..sort((a, b) => sortKey(a).compareTo(sortKey(b))))
        _categoryNode(wl, c, byCat[c]!, categories, sortKey),
    ];

    final tagCounts = {for (final k in tagKeys) k: total(k)};
    final all = total('total');
    return TreeNode(
      id: NodeIds.wordlist(wl),
      kind: NodeKind.wordlist,
      name: list.name,
      count: all,
      children: [
        TreeNode(
          id: NodeIds.packs(wl),
          kind: NodeKind.packs,
          count: all,
          learned: packs.where((p) => p.status == PackStatus.learned).length,
          children: packs,
        ),
        TreeNode(
          id: NodeIds.categories(wl),
          kind: NodeKind.categories,
          count: all - total('uncat'),
          children: categoryNodes,
        ),
        TreeNode(
          id: NodeIds.tags(wl),
          kind: NodeKind.tags,
          count: all - tagCounts['untagged']!,
          children: [
            for (final k in tagKeys)
              TreeNode(
                id: NodeIds.tag(wl, k),
                kind: NodeKind.tag,
                tagKey: k,
                count: tagCounts[k]!,
              ),
          ],
        ),
        TreeNode(
          id: NodeIds.uncategorised(wl),
          kind: NodeKind.uncategorised,
          count: total('uncat'),
        ),
      ],
    );
  }

  TreeNode _categoryNode(
    String wl,
    String catId,
    Map<String?, int> bySub,
    Map<String, Category> categories,
    String Function(String) sortKey,
  ) {
    final subs = bySub.keys.whereType<String>().toList()
      ..sort((a, b) => sortKey(a).compareTo(sortKey(b)));
    final withoutSub = bySub[null] ?? 0;
    return TreeNode(
      id: NodeIds.category(wl, catId),
      kind: NodeKind.category,
      name: categories[catId]?.name,
      count: bySub.values.fold(0, (a, b) => a + b),
      children: [
        for (final s in subs)
          TreeNode(
            id: NodeIds.subcategory(wl, s),
            kind: NodeKind.subcategory,
            name: categories[s]?.name,
            count: bySub[s]!,
          ),
        // "(no subcategory)" only when the category has subcategories too.
        if (subs.isNotEmpty && withoutSub > 0)
          TreeNode(
            id: NodeIds.noSubcategory(wl, catId),
            kind: NodeKind.noSubcategory,
            count: withoutSub,
          ),
      ],
    );
  }

  /// The words under a node, updated live. Pack, packs and wordlist nodes are
  /// in source order; category, tag, uncategorised and search nodes are
  /// alphabetical.
  Stream<List<Word>> watchWords(String nodeId) {
    final ref = NodeIds.parse(nodeId);
    if (ref == null) return Stream.value(const []);
    final q = _db.select(_db.words);
    final wl = ref.wordlistId;
    var alphabetical = true;
    switch (ref.kind) {
      case NodeKind.wordlist || NodeKind.packs:
        q.where((w) => w.wordlistId.equals(wl!));
        alphabetical = false;
      case NodeKind.pack:
        q.where((w) => w.packId.equals(ref.targetId!));
        alphabetical = false;
      case NodeKind.categories:
        q.where((w) => w.wordlistId.equals(wl!) & w.categoryId.isNotNull());
      case NodeKind.category:
        q.where(
          (w) => w.wordlistId.equals(wl!) & w.categoryId.equals(ref.targetId!),
        );
      case NodeKind.subcategory:
        q.where(
          (w) =>
              w.wordlistId.equals(wl!) & w.subcategoryId.equals(ref.targetId!),
        );
      case NodeKind.noSubcategory:
        q.where(
          (w) =>
              w.wordlistId.equals(wl!) &
              w.categoryId.equals(ref.targetId!) &
              w.subcategoryId.isNull(),
        );
      case NodeKind.uncategorised:
        q.where((w) => w.wordlistId.equals(wl!) & w.categoryId.isNull());
      case NodeKind.tags:
        q.where(
          (w) =>
              w.wordlistId.equals(wl!) &
              (w.tone.isNotNull() |
                  w.counterIntuitive.equals(true) |
                  w.multipleMeanings.equals(true)),
        );
      case NodeKind.tag:
        q.where((w) => w.wordlistId.equals(wl!) & _tagFilter(w, ref.tagKey!));
      case NodeKind.search:
        final pattern = '%${_escapeLike(ref.query!.toLowerCase())}%';
        q.where(
          (w) =>
              w.term.lower().like(pattern, escapeChar: r'\') |
              w.definition.lower().like(pattern, escapeChar: r'\'),
        );
    }
    q.orderBy([
      if (alphabetical) (w) => OrderingTerm.asc(w.term.lower()),
      (w) => OrderingTerm.asc(w.position),
      (w) => OrderingTerm.asc(w.wordlistId),
    ]);
    return q.watch();
  }

  Expression<bool> _tagFilter($WordsTable w, String key) => switch (key) {
    'positive' => w.tone.equalsValue(Tone.positive),
    'negative' => w.tone.equalsValue(Tone.negative),
    'neutral' => w.tone.equalsValue(Tone.neutral),
    'counterIntuitive' => w.counterIntuitive.equals(true),
    'multipleMeanings' => w.multipleMeanings.equals(true),
    _ =>
      w.tone.isNull() &
          w.counterIntuitive.equals(false) &
          w.multipleMeanings.equals(false),
  };

  static String _escapeLike(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

  /// Ids of packs that are Learned under the current rule (which words may
  /// be tagged in the explorer).
  Stream<Set<String>> watchLearnedPackIds() => _db
      .customSelect('SELECT 1', readsFrom: {_db.packs, _db.appSettings})
      .watch()
      .asyncMap((_) async {
        final rule = (await (_db.select(
          _db.appSettings,
        )..where((s) => s.id.equals(1))).getSingle()).learnedRule;
        return {
          for (final p in await _db.select(_db.packs).get())
            if (isLearned(p.masteryWd, p.masteryDw, rule)) p.id,
        };
      });
}
