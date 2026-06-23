import 'package:flutter/material.dart';
import 'dart:math';

class TexturePattern extends StatelessWidget {
  final Widget child;
  final Color color;
  final double opacity;

  const TexturePattern({
    super.key,
    required this.child,
    required this.color,
    this.opacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: DotGridPainter(color: color.withValues(alpha: opacity)),
          ),
        ),
        child,
      ],
    );
  }
}

class DotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double radius;

  DotGridPainter({
    required this.color,
    this.spacing = 12.0,
    this.radius = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotGridPainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.spacing != spacing ||
           oldDelegate.radius != radius;
  }
}

class DiagonalStripesPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double strokeWidth;

  DiagonalStripesPainter({
    required this.color,
    this.spacing = 16.0,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double diagonal = sqrt(size.width * size.width + size.height * size.height);
    
    // Draw lines at 45 degrees
    for (double i = -diagonal; i < diagonal; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + diagonal, diagonal),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DiagonalStripesPainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.spacing != spacing ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
