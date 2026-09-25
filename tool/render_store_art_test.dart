// Renders the Play Store listing graphics into store/: the 512 × 512 icon and
// the 1024 × 500 feature graphic. Not part of the test suite:
//   flutter test tool/render_store_art_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'render_icon_test.dart' show paintIcon;

const _primary = Color(0xFF2F4A8A);
const _onPrimary = Color(0xFFFFFFFF);
const _tonal = Color(0xFFD0DBFA);

Future<void> _load(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(File(f).readAsBytes().then((b) => ByteData.sublistView(b)));
  }
  await loader.load();
}

Future<void> _write(
  String path,
  int w,
  int h,
  void Function(Canvas) paint,
) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder));
  final image = await recorder.endRecording().toImage(w, h);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(png!.buffer.asUint8List());
}

TextPainter _text(String s, TextStyle style, {double? maxWidth}) => TextPainter(
  text: TextSpan(text: s, style: style),
  textDirection: TextDirection.ltr,
)..layout(maxWidth: maxWidth ?? double.infinity);

void _feature(Canvas c) {
  c.drawRect(const Rect.fromLTWH(0, 0, 1024, 500), Paint()..color = _primary);

  // The icon's card stack, without its square background, on the left.
  c.save();
  c.translate(40, 20);
  c.scale(460 / 1024);
  paintIcon(c, background: false);
  c.restore();

  const x = 500.0;
  final title = _text(
    'WordPack',
    const TextStyle(
      fontFamily: 'Literata',
      fontSize: 84,
      fontVariations: [ui.FontVariation.weight(600)],
      color: _onPrimary,
    ),
  );
  final tagline = _text(
    'Learn vocabulary one small pack at a time — no peeking.',
    const TextStyle(
      fontFamily: 'AtkinsonHyperlegibleNext',
      fontSize: 32,
      height: 1.3,
      fontVariations: [ui.FontVariation.weight(500)],
      color: _tonal,
    ),
    maxWidth: 460,
  );
  final top = (500 - title.height - 16 - tagline.height) / 2;
  title.paint(c, Offset(x, top));
  tagline.paint(c, Offset(x, top + title.height + 16));
}

void main() {
  testWidgets('render store art', (tester) async {
    await tester.runAsync(() async {
      await _load('Literata', ['assets/fonts/Literata-Variable.ttf']);
      await _load('AtkinsonHyperlegibleNext', [
        'assets/fonts/AtkinsonHyperlegibleNext-Variable.ttf',
      ]);
      await _write('store/icon-512.png', 512, 512, (c) {
        c.scale(0.5);
        paintIcon(c);
      });
      await _write('store/feature-graphic.png', 1024, 500, _feature);
    });
  });
}
