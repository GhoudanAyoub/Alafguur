import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class VideoImCallWidgetRipplesAnimation extends CustomPainter {
  final Animation<double> animation;
  final Color ripplesColor;

  const VideoImCallWidgetRipplesAnimation(
    this.animation, {
    required this.ripplesColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);

    for (int wave = 3; wave >= 0; wave--) {
      _paintRipple(canvas, rect, animation.value + wave);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  /// Paint a ripple on the given [canvas].
  void _paintRipple(Canvas canvas, Rect rect, double value) {
    final size = rect.width / 2;
    final area = size * size;
    final radius = math.sqrt(area * value / 4);
    final opacity = (1.0 - (value / 4.0)).clamp(0.0, 1.0).toDouble();
    final color = ripplesColor.withOpacity(opacity);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color;

    canvas.drawCircle(rect.center, radius, paint);
  }
}
