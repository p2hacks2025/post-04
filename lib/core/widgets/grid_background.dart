import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GridBackground extends StatelessWidget {
  const GridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _GridBackgroundPainter());
  }
}

class _GridBackgroundPainter extends CustomPainter {
  const _GridBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double step = 24;
    final paint = Paint()
      ..color = AppColors.gridLine
      ..strokeWidth = 1.0;

    final double width = size.width;
    final double height = size.height;

    for (double x = 0; x <= width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), paint);
    }
    for (double y = 0; y <= height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
