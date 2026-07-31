import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:melody_sense/core/theme/app_colors.dart';

/// Painter untuk tekstur stripe diagonal halus (Desain.md Section 3.6)
class StripePatternPainter extends CustomPainter {
  StripePatternPainter({
    this.color,
    this.stripeWidth = 1.5,
    this.spacing = 12.0,
    this.opacity = 0.35,
  });

  final Color? color;
  final double stripeWidth;
  final double spacing;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveColor = color ?? AppColors.surfaceTint;
    final paint = Paint()
      ..color = effectiveColor.withValues(alpha: opacity)
      ..strokeWidth = stripeWidth
      ..style = PaintingStyle.stroke;

    final startX = -size.height;
    final endX = size.width + size.height;
    for (double x = startX; x < endX; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StripePatternPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.stripeWidth != stripeWidth ||
        oldDelegate.spacing != spacing ||
        oldDelegate.opacity != opacity;
  }
}

/// Painter untuk aksen halftone dot dekoratif (Desain.md Section 3.3)
class HalftonePatternPainter extends CustomPainter {
  HalftonePatternPainter({
    this.color,
    this.maxRadius = 3.5,
    this.spacing = 10.0,
    this.opacity = 0.4,
  });

  final Color? color;
  final double maxRadius;
  final double spacing;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveColor = color ?? AppColors.surfaceTint;
    final paint = Paint()..style = PaintingStyle.fill;

    final maxDist = math.sqrt(size.width * size.width + size.height * size.height);
    if (maxDist == 0) return;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      final ySq = y * y;
      for (double x = spacing / 2; x < size.width; x += spacing) {
        final distFromCorner = math.sqrt(x * x + ySq);
        final factor = (1.0 - (distFromCorner / maxDist)).clamp(0.1, 1.0);

        final radius = maxRadius * factor;
        paint.color = effectiveColor.withValues(alpha: opacity * factor);

        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HalftonePatternPainter oldDelegate) => false;
}

/// Widget Divider bergaya garis sobek horizontal (Desain.md Section 3.7)
class TornDivider extends StatelessWidget {
  const TornDivider({
    super.key,
    this.color,
    this.height = 12.0,
    this.opacity = 0.3,
  });

  final Color? color;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryDark;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _TornDividerPainter(color: effectiveColor.withValues(alpha: opacity)),
      ),
    );
  }
}

class _TornDividerPainter extends CustomPainter {
  _TornDividerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(0, size.height / 2);

    const jagWidth = 10.0;
    const jagAmp = 3.0;

    double currentX = 0;
    int step = 0;

    while (currentX < size.width) {
      final nextX = (currentX + jagWidth).clamp(0.0, size.width);
      final yOffset = (step % 2 == 0) ? jagAmp : -jagAmp;
      path.lineTo(nextX, (size.height / 2) + yOffset);
      currentX = nextX;
      step++;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TornDividerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
