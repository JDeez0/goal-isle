import 'package:flutter/material.dart';

class MountainVisual extends StatelessWidget {
  final double mass;
  final double height;
  final double width;

  const MountainVisual({
    super.key,
    required this.mass,
    this.height = 200,
    this.width = 300,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate mountain height based on mass
    final mountainHeight = (height * 0.3) + (height * 0.7 * (mass / 100).clamp(0, 1));
    
    return CustomPaint(
      size: Size(width, height),
      painter: MountainPainter(mass: mass, mountainHeight: mountainHeight),
    );
  }
}

class MountainPainter extends CustomPainter {
  final double mass;
  final double mountainHeight;

  MountainPainter({required this.mass, required this.mountainHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1F2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = const Color(0xFF1A1F2E).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Main mountain shape (abstract, geometric, starts bottom left, rises steeply)
    final path = Path();
    
    // Start at bottom left
    path.moveTo(0, size.height);
    
    // Rising steeply
    path.lineTo(size.width * 0.15, size.height * 0.4);
    
    // Peak
    path.lineTo(size.width * 0.3, size.height * 0.2);
    
    // Sloping down
    path.lineTo(size.width * 0.7, size.height * 0.5);
    
    // Another peak
    path.lineTo(size.width * 0.85, size.height * 0.35);
    
    // End at bottom right
    path.lineTo(size.width, size.height);
    
    // Close path
    path.close();

    // Fill mountain
    canvas.drawPath(path, fillPaint);
    
    // Draw mountain outline
    canvas.drawPath(path, paint);

    // Add sparse geometric lines
    _drawSparseLines(canvas, size, paint);
  }

  void _drawSparseLines(Canvas canvas, Size size, Paint paint) {
    // Sparse horizontal lines for "sparse line pattern" aesthetic
    final linePaint = Paint()
      ..color = const Color(0xFF374151).withOpacity(0.3)
      ..strokeWidth = 0.5;

    for (double y = size.height * 0.6; y < size.height; y += size.height * 0.1) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    // Sparse vertical lines
    for (double x = size.width * 0.2; x < size.width; x += size.width * 0.15) {
      canvas.drawLine(
        Offset(x, size.height * 0.5),
        Offset(x, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}