// Renders the app icon from the design canvas (Handoff › App icon) to PNGs.
// Not part of the test suite; run it after changing the icon, then
// `dart run flutter_launcher_icons`:
//   flutter test tool/render_icon_test.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _primary = Color(0xFF2F4A8A);
const _paper = Color(0xFFFFFDF8);
const _line = Color(0xFFE0D9CB);
const _learned = Color(0xFF2B7A4B);

/// The 1024 × 1024 artwork; [background] false leaves it transparent (the
/// Android adaptive-icon foreground), [scale] shrinks it into the safe zone.
void paintIcon(Canvas c, {bool background = true, double scale = 1}) {
  if (background) {
    c.drawRect(
      const Rect.fromLTWH(0, 0, 1024, 1024),
      Paint()..color = _primary,
    );
  }
  c.save();
  c.translate(512, 512);
  c.scale(scale);
  c.translate(-512, -512);

  void card(double x, double y, double deg, double cx, double cy, double a) {
    c.save();
    c.translate(cx, cy);
    c.rotate(deg * math.pi / 180);
    c.translate(-cx, -cy);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, 500, 620),
        const Radius.circular(64),
      ),
      Paint()..color = _paper.withValues(alpha: a),
    );
    c.restore();
  }

  card(286, 206, 9, 536, 516, 0.28);
  card(262, 218, 4, 512, 528, 0.55);
  card(238, 200, 0, 0, 0, 1);

  final w = TextPainter(
    text: const TextSpan(
      text: 'W',
      style: TextStyle(
        fontFamily: 'Literata',
        fontSize: 380,
        fontWeight: FontWeight.w600,
        fontVariations: [ui.FontVariation.weight(600)],
        color: _primary,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final baseline = w.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  w.paint(c, Offset(488 - w.width / 2, 600 - baseline));

  RRect bar(double width) => RRect.fromRectAndRadius(
    Rect.fromLTWH(330, 690, width, 14),
    const Radius.circular(7),
  );
  c.drawRRect(bar(316), Paint()..color = _line);
  c.drawRRect(bar(190), Paint()..color = _learned);
  c.restore();
}

Future<void> _write(
  String path, {
  bool background = true,
  double scale = 1,
}) async {
  final recorder = ui.PictureRecorder();
  paintIcon(Canvas(recorder), background: background, scale: scale);
  final image = await recorder.endRecording().toImage(1024, 1024);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(png!.buffer.asUint8List());
}

void main() {
  testWidgets('render app icon', (tester) async {
    await tester.runAsync(() async {
      final loader = FontLoader('Literata')
        ..addFont(
          File(
            'assets/fonts/Literata-Variable.ttf',
          ).readAsBytes().then((b) => ByteData.sublistView(b)),
        );
      await loader.load();
      await _write('assets/icon/app_icon.png');
      // Adaptive icons crop to a circle/squircle: keep the cards inside the
      // central safe zone on a transparent layer.
      await _write(
        'assets/icon/app_icon_foreground.png',
        background: false,
        scale: 0.92,
      );
    });
  });
}
