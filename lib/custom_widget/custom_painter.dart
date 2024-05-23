import 'package:flutter/material.dart';

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round // Change stroke cap for a rounded end
      ..style = PaintingStyle.stroke;

    // Draw background line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    paint.color = color;
    double progress = animation.value * size.width;
    // Draw progress line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(progress, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomTimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
