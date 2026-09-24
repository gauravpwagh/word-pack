import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

/// A dashed rounded-rectangle outline: the counter-intuitive marker
/// (2 px, dash 6 / gap 4, `docs/UI_UX.md` §9).
class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 2,
    this.dash = 6,
    this.gap = 4,
    this.inset = 0,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  /// Distance from the edge (list rows use 4).
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(inset + strokeWidth / 2);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final PathMetric metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = (d + dash).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(d, end), paint);
        d = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dash != dash ||
      old.gap != gap ||
      old.inset != inset;
}
