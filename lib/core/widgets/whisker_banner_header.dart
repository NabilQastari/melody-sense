import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melody_sense/core/theme/app_colors.dart';

/// Header Banner bertema "The Whisker Watch"
/// Pita/Banner miring ber-outline ink tebal dengan teks komik bergaris tepi (Desain.md)
class WhiskerBannerHeader extends StatelessWidget {
  const WhiskerBannerHeader({
    super.key,
    required this.title,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.rotateAngle = -0.06, // ~-3.5 derajat
    this.fontSize = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  final String title;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double rotateAngle;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.surfaceWhite;
    final bColor = borderColor ?? AppColors.primaryDark;
    final tColor = textColor ?? AppColors.primaryDark;

    return Transform.rotate(
      angle: rotateAngle,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: bColor, width: 2.8),
          boxShadow: [
            BoxShadow(
              color: bColor.withValues(alpha: 0.25),
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Text(
          title,
          style: GoogleFonts.fredoka(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: tColor,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
