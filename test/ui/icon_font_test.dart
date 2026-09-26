import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/ui/theme/wp_icons.dart';

/// Table tags in a TrueType font's table directory.
Set<String> tableTags(String path) {
  final data = ByteData.sublistView(File(path).readAsBytesSync());
  final count = data.getUint16(4);
  return {
    for (var i = 0; i < count; i++)
      String.fromCharCodes(
        Uint8List.sublistView(data, 12 + 16 * i, 16 + 16 * i),
      ),
  };
}

void main() {
  // Release builds tree-shake icon fonts, and Flutter's subsetter corrupts
  // variable fonts: icons went missing on devices (D-21). The icon fonts must
  // stay static.
  for (final family in ['WpSymbols', 'WpSymbolsFilled']) {
    test('$family.ttf is a static font', () {
      final tags = tableTags('assets/fonts/$family.ttf');
      expect(tags, containsAll(['cmap', 'glyf']));
      expect(tags, isNot(contains('fvar')));
      expect(tags, isNot(contains('gvar')));
    });
  }

  test('filled forms exist for every icon', () {
    for (final icon in [WpIcons.checkCircle, WpIcons.school, WpIcons.menu]) {
      final filled = WpIcons.filled(icon);
      expect(filled.codePoint, icon.codePoint);
      expect(filled.fontFamily, 'WpSymbolsFilled');
    }
  });

  test('the variable Material Symbols package is not used', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, isNot(contains('material_symbols_icons')));
  });
}
