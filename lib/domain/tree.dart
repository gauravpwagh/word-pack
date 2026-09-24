/// The explorer tree (`docs/UI_UX.md` §8): node ids, node model and the
/// flattening used by the tree view. Pure Dart.
library;

import 'models.dart';

enum NodeKind {
  wordlist,
  packs,
  pack,
  categories,
  category,
  subcategory,
  noSubcategory,
  uncategorised,
  tags,
  tag,
  search,
}

/// Tag node keys: tones, traits, and words with no tag at all.
const tagKeys = [
  'positive',
  'negative',
  'neutral',
  'counterIntuitive',
  'multipleMeanings',
  'untagged',
];

/// A parsed node id.
final class NodeRef {
  const NodeRef(
    this.kind, {
    this.wordlistId,
    this.targetId,
    this.tagKey,
    this.query,
  });

  final NodeKind kind;
  final String? wordlistId;

  /// Pack, category or subcategory id.
  final String? targetId;
  final String? tagKey;
  final String? query;

  @override
  bool operator ==(Object other) =>
      other is NodeRef &&
      other.kind == kind &&
      other.wordlistId == wordlistId &&
      other.targetId == targetId &&
      other.tagKey == tagKey &&
      other.query == query;

  @override
  int get hashCode => Object.hash(kind, wordlistId, targetId, tagKey, query);

  @override
  String toString() =>
      'NodeRef(${kind.name}, $wordlistId, $targetId, '
      '$tagKey, $query)';
}

/// Node ids: `wl:<id>`, `wl:<id>:packs`, `pack:<id>`, `wl:<id>:cats`,
/// `cat:<wlId>:<catId>`, `sub:<wlId>:<subId>`, `nosub:<wlId>:<catId>`,
/// `wl:<id>:uncat`, `wl:<id>:tags`, `tag:<wlId>:<key>`, `search:<query>`.
abstract final class NodeIds {
  static String wordlist(String id) => 'wl:$id';
  static String packs(String wl) => 'wl:$wl:packs';
  static String pack(String id) => 'pack:$id';
  static String categories(String wl) => 'wl:$wl:cats';
  static String category(String wl, String cat) => 'cat:$wl:$cat';
  static String subcategory(String wl, String sub) => 'sub:$wl:$sub';
  static String noSubcategory(String wl, String cat) => 'nosub:$wl:$cat';
  static String uncategorised(String wl) => 'wl:$wl:uncat';
  static String tags(String wl) => 'wl:$wl:tags';
  static String tag(String wl, String key) => 'tag:$wl:$key';
  static String search(String query) => 'search:$query';

  /// Null for anything malformed.
  static NodeRef? parse(String id) {
    if (id.startsWith('search:')) {
      final q = id.substring(7).trim();
      return q.isEmpty ? null : NodeRef(NodeKind.search, query: q);
    }
    final p = id.split(':');
    if (p.any((s) => s.isEmpty)) return null;
    return switch (p) {
      ['wl', final wl] => NodeRef(NodeKind.wordlist, wordlistId: wl),
      ['wl', final wl, 'packs'] => NodeRef(NodeKind.packs, wordlistId: wl),
      ['wl', final wl, 'cats'] => NodeRef(NodeKind.categories, wordlistId: wl),
      ['wl', final wl, 'uncat'] => NodeRef(
        NodeKind.uncategorised,
        wordlistId: wl,
      ),
      ['wl', final wl, 'tags'] => NodeRef(NodeKind.tags, wordlistId: wl),
      ['pack', final id] => NodeRef(NodeKind.pack, targetId: id),
      ['cat', final wl, final c] => NodeRef(
        NodeKind.category,
        wordlistId: wl,
        targetId: c,
      ),
      ['sub', final wl, final s] => NodeRef(
        NodeKind.subcategory,
        wordlistId: wl,
        targetId: s,
      ),
      ['nosub', final wl, final c] => NodeRef(
        NodeKind.noSubcategory,
        wordlistId: wl,
        targetId: c,
      ),
      ['tag', final wl, final k] when tagKeys.contains(k) => NodeRef(
        NodeKind.tag,
        wordlistId: wl,
        tagKey: k,
      ),
      _ => null,
    };
  }
}

/// One node of the tree. Display text comes from the UI (localised) using
/// [kind], [name], [packNumber] and [tagKey].
final class TreeNode {
  const TreeNode({
    required this.id,
    required this.kind,
    required this.count,
    this.name,
    this.packNumber,
    this.status,
    this.tagKey,
    this.learned,
    this.children = const [],
  });

  final String id;
  final NodeKind kind;

  /// Words under this node.
  final int count;

  /// Wordlist, category or subcategory name.
  final String? name;
  final int? packNumber;
  final PackStatus? status;
  final String? tagKey;

  /// For the Packs node: how many packs are Learned (`5 / 34`).
  final int? learned;
  final List<TreeNode> children;

  bool get hasChildren => children.isNotEmpty;
}

/// A visible row of the flattened tree.
typedef TreeRow = ({TreeNode node, int depth, bool expanded});

/// The rows to show: every root, and the children of expanded nodes.
List<TreeRow> flattenTree(List<TreeNode> roots, Set<String> expanded) {
  final rows = <TreeRow>[];
  void visit(TreeNode n, int depth) {
    final open = n.hasChildren && expanded.contains(n.id);
    rows.add((node: n, depth: depth, expanded: open));
    if (open) {
      for (final c in n.children) {
        visit(c, depth + 1);
      }
    }
  }

  for (final r in roots) {
    visit(r, 0);
  }
  return rows;
}

/// The nodes from a root down to [id], or empty when [id] is not in the tree.
List<TreeNode> findPath(List<TreeNode> roots, String id) {
  for (final r in roots) {
    if (r.id == id) return [r];
    final below = findPath(r.children, id);
    if (below.isNotEmpty) return [r, ...below];
  }
  return const [];
}
