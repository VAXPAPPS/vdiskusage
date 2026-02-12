import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated circular percentage indicator.
class CircularUsageIndicator extends StatelessWidget {
  final double percentage;
  final double size;
  final double strokeWidth;
  final Color? color;

  const CircularUsageIndicator({
    super.key,
    required this.percentage,
    this.size = 60,
    this.strokeWidth = 5,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor =
        color ?? _getColorForPercentage(percentage);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: percentage),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return CustomPaint(
            painter: _CircularPainter(
              percentage: value,
              color: displayColor,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.white.withOpacity(0.08),
            ),
            child: Center(
              child: Text(
                '${value.toInt()}%',
                style: TextStyle(
                  color: displayColor,
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getColorForPercentage(double pct) {
    if (pct > 90) return const Color(0xFFEF5350);
    if (pct > 75) return const Color(0xFFFFB74D);
    return const Color(0xFF66BB6A);
  }
}

class _CircularPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final double strokeWidth;
  final Color backgroundColor;

  const _CircularPainter({
    required this.percentage,
    required this.color,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.color != color;
  }
}
