import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class DashboardTinderLoadingWidgetRadarAnimation extends CustomPainter {
  final Animation<double> animation;
  final Color strokeColor;
  final List<Color> gradientStops;
  final double gradientAngle;

  const DashboardTinderLoadingWidgetRadarAnimation(
    this.animation, {
    required this.strokeColor,
    required this.gradientStops,
    required this.gradientAngle,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);

    // Bigger wave.
    _paintWave(canvas, rect, animation.value + 1);

    // Smaller wave.
    _paintWave(canvas, rect, animation.value);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  /// Paint a wave on the given [canvas].
  void _paintWave(Canvas canvas, Rect rect, double value) {
    final size = rect.width * 1.2;
    final area = size * size;
    final radius = math.sqrt(area * value / 2.0);
    final opacity = (1.0 - (value / 2.0)).clamp(0.0, 1.0).toDouble();

    final actualGradientStops =
        gradientStops.map((stop) => stop.withOpacity(opacity)).toList();

    final actualStrokeColor = strokeColor.withOpacity(opacity);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..color = actualStrokeColor;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: actualGradientStops,
        transform: GradientRotation(
          gradientAngle * (3.14 / 180),
        ),
      ).createShader(rect);

    // Draw stroke.
    canvas.drawCircle(rect.center, radius, strokePaint);

    // Draw fill.
    canvas.drawCircle(rect.center, radius, fillPaint);
  }
}
