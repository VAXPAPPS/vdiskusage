import 'package:flutter/material.dart';

/// A horizontal bar representing relative size.
class SizeBar extends StatelessWidget {
  final int value;
  final int maxValue;
  final Color color;
  final double height;

  const SizeBar({
    super.key,
    required this.value,
    required this.maxValue,
    this.color = const Color(0xFF64B5F6),
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            // Background
            Container(
              color: Colors.white.withOpacity(0.06),
            ),
            // Fill
            FractionallySizedBox(
              widthFactor: fraction,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.6),
                      color.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
