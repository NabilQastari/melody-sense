import 'package:flutter/material.dart';
import 'package:melody_sense/core/theme/app_colors.dart';

enum TornEdgePosition { top, bottom, both, none }

/// Widget Card berkarakter "Torn Paper" (kertas sobek dengan comic-ink outline)
/// yang presisi, simetris, dan konsisten (Desain.md).
class TornPaperCard extends StatelessWidget {
  const TornPaperCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.shadowColor,
    this.borderColor,
    this.borderWidth = 2.5,
    this.tornPosition = TornEdgePosition.bottom,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.elevationOffset = const Offset(6, 6),
    this.width,
    this.height,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? borderColor;
  final double borderWidth;
  final TornEdgePosition tornPosition;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Offset elevationOffset;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.surfaceWhite;
    final sColor = shadowColor ?? AppColors.surfaceTint;
    final bColor = borderColor ?? AppColors.primaryDark;

    return Container(
      margin: margin,
      width: width,
      height: height,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _TornPaperPainter(
            fillColor: bgColor,
            shadowColor: sColor,
            borderColor: bColor,
            borderWidth: borderWidth,
            tornPosition: tornPosition,
            elevationOffset: elevationOffset,
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _TornPaperPainter extends CustomPainter {
  _TornPaperPainter({
    required this.fillColor,
    required this.shadowColor,
    required this.borderColor,
    required this.borderWidth,
    required this.tornPosition,
    required this.elevationOffset,
  });

  final Color fillColor;
  final Color shadowColor;
  final Color borderColor;
  final double borderWidth;
  final TornEdgePosition tornPosition;
  final Offset elevationOffset;

  Path? _cachedPath;
  Path? _cachedShadowPath;
  Size? _cachedSize;

  Path _getPath(Size size) {
    if (_cachedPath != null && _cachedSize == size) {
      return _cachedPath!;
    }
    _cachedSize = size;
    _cachedPath = _createTornPath(size);
    _cachedShadowPath = _cachedPath!.shift(elevationOffset);
    return _cachedPath!;
  }

  Path _createTornPath(Size size) {
    final path = Path();
    const radius = 14.0;
    const jagAmplitude = 6.0;
    const jagWidth = 16.0;

    // Start Top-Left
    path.moveTo(radius, 0);

    // Top Edge
    if (tornPosition == TornEdgePosition.top || tornPosition == TornEdgePosition.both) {
      double currentX = radius;
      final endX = size.width - radius;
      int step = 0;

      while (currentX < endX) {
        final nextX = (currentX + jagWidth).clamp(radius, endX);
        final yVal = (step % 2 == 0) ? jagAmplitude : 0.0;
        path.lineTo(nextX, yVal);
        currentX = nextX;
        step++;
      }
    } else {
      path.lineTo(size.width - radius, 0);
    }

    // Top-Right Corner
    path.arcToPoint(
      Offset(size.width, radius),
      radius: const Radius.circular(radius),
    );

    // Right Edge
    path.lineTo(size.width, size.height - radius);

    // Bottom-Right Corner
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: const Radius.circular(radius),
    );

    // Bottom Edge
    if (tornPosition == TornEdgePosition.bottom || tornPosition == TornEdgePosition.both) {
      double currentX = size.width - radius;
      const endX = radius;
      int step = 0;

      while (currentX > endX) {
        final nextX = (currentX - jagWidth).clamp(endX, size.width - radius);
        final yVal = size.height - ((step % 2 == 0) ? jagAmplitude : 0.0);
        path.lineTo(nextX, yVal);
        currentX = nextX;
        step++;
      }
    } else {
      path.lineTo(radius, size.height);
    }

    // Bottom-Left Corner
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: const Radius.circular(radius),
    );

    // Left Edge
    path.lineTo(0, radius);

    // Top-Left Corner
    path.arcToPoint(
      const Offset(radius, 0),
      radius: const Radius.circular(radius),
    );

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _getPath(size);
    final shadowPath = _cachedShadowPath ?? path.shift(elevationOffset);

    // 1. Shadow/Paper Stack Duplicate Layer
    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(shadowPath, shadowPaint);

    final shadowBorderPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(shadowPath, shadowBorderPaint);

    // 2. Main Card Fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 3. Comic-Ink Outline
    final outlinePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _TornPaperPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.tornPosition != tornPosition ||
        oldDelegate.elevationOffset != elevationOffset;
  }
}
