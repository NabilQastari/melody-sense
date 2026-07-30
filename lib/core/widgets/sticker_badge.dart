import 'package:flutter/material.dart';
import 'package:melody_sense/core/theme/app_colors.dart';

/// Widget Sticker Badge miring berkarakter comic-ink (Desain.md Section 3.2)
class StickerBadge extends StatelessWidget {
  const StickerBadge({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.rotateAngle = -0.05, // ~-3 derajat
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.borderRadius = 16.0,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double rotateAngle;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.accent;
    final borderCol = borderColor ?? AppColors.primaryDark;

    return Transform.rotate(
      angle: rotateAngle,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderCol,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.15),
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
