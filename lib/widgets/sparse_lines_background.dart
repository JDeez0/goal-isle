import 'package:flutter/material.dart';

class SparseLinesBackground extends StatelessWidget {
  const SparseLinesBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _SparseLinesPainter(),
    );
  }
}

class _SparseLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF374151).withOpacity(0.15)
      ..strokeWidth = 0.5;

    // Sparse horizontal lines
    for (double y = 0; y < size.height; y += 80) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Sparse vertical lines
    for (double x = 0; x < size.width; x += 80) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}