import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/domain/tree.dart';

void main() {
  group('node ids', () {
    test('round-trip every kind', () {
      final cases = {
        NodeIds.wordlist('L'): const NodeRef(
          NodeKind.wordlist,
          wordlistId: 'L',
        ),
        NodeIds.packs('L'): const NodeRef(NodeKind.packs, wordlistId: 'L'),
        NodeIds.pack('P'): const NodeRef(NodeKind.pack, targetId: 'P'),
        NodeIds.categories('L'): const NodeRef(
          NodeKind.categories,
          wordlistId: 'L',
        ),
        NodeIds.category('L', 'C'): const NodeRef(
          NodeKind.category,
          wordlistId: 'L',
          targetId: 'C',
        ),
        NodeIds.subcategory('L', 'S'): const NodeRef(
          NodeKind.subcategory,
          wordlistId: 'L',
          targetId: 'S',
        ),
        NodeIds.noSubcategory('L', 'C'): const NodeRef(
          NodeKind.noSubcategory,
          wordlistId: 'L',
          targetId: 'C',
        ),
        NodeIds.uncategorised('L'): const NodeRef(
          NodeKind.uncategorised,
          wordlistId: 'L',
        ),
        NodeIds.tags('L'): const NodeRef(NodeKind.tags, wordlistId: 'L'),
        NodeIds.tag('L', 'untagged'): const NodeRef(
          NodeKind.tag,
          wordlistId: 'L',
          tagKey: 'untagged',
        ),
        NodeIds.search('a:b c'): const NodeRef(NodeKind.search, query: 'a:b c'),
      };
      for (final MapEntry(key: id, value: ref) in cases.entries) {
        expect(NodeIds.parse(id), ref, reason: id);
        expect(NodeIds.parse(id).hashCode, ref.hashCode);
      }
      expect(
        NodeIds.parse('pack:P').toString(),
        'NodeRef(pack, null, P, null, null)',
      );
    });

    test('malformed ids are rejected', () {
      for (final id in [
        '',
        'wl:',
        'wl::packs',
        'wl:L:nope',
        'tag:L:shiny',
        'search:  ',
        'cat:L',
        'x:y',
      ]) {
        expect(NodeIds.parse(id), isNull, reason: id);
      }
    });
  });

  group('flatten and path', () {
    const tree = [
      TreeNode(
        id: 'a',
        kind: NodeKind.wordlist,
        count: 3,
        children: [
          TreeNode(
            id: 'a1',
            kind: NodeKind.categories,
            count: 2,
            children: [TreeNode(id: 'a1x', kind: NodeKind.category, count: 2)],
          ),
          TreeNode(id: 'a2', kind: NodeKind.uncategorised, count: 1),
        ],
      ),
      TreeNode(id: 'b', kind: NodeKind.wordlist, count: 0),
    ];

    List<String> ids(Set<String> expanded) => [
      for (final r in flattenTree(tree, expanded))
        '${'  ' * r.depth}${r.node.id}${r.expanded ? '-' : ''}',
    ];

    test('collapsed shows roots only', () {
      expect(ids({}), ['a', 'b']);
    });

    test('expanded nodes show their children, depth-first', () {
      expect(ids({'a'}), ['a-', '  a1', '  a2', 'b']);
      expect(ids({'a', 'a1'}), ['a-', '  a1-', '    a1x', '  a2', 'b']);
      expect(ids({'a1'}), ['a', 'b'], reason: 'parent collapsed');
      expect(ids({'b', 'a2'}), ['a', 'b'], reason: 'leaves never expand');
    });

    test('findPath', () {
      expect([for (final n in findPath(tree, 'a1x')) n.id], ['a', 'a1', 'a1x']);
      expect([for (final n in findPath(tree, 'b')) n.id], ['b']);
      expect(findPath(tree, 'zzz'), isEmpty);
      expect(tree.first.hasChildren, isTrue);
      expect(tree.last.hasChildren, isFalse);
    });
  });
}
