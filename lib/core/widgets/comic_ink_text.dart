import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melody_sense/core/theme/app_colors.dart';

/// Widget Teks bertema "Comic-Ink" (Outline ganda + solid offset-shadow)
/// sesuai spesifikasi Desain.md (Section 3.4 & 4).
class ComicInkText extends StatelessWidget {
  const ComicInkText(
    this.text, {
    super.key,
    this.fontSize = 24,
    this.textColor,
    this.outlineColor,
    this.shadowColor,
    this.fontWeight = FontWeight.w900,
    this.letterSpacing = -0.5,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final double fontSize;
  final Color? textColor;
  final Color? outlineColor;
  final Color? shadowColor;
  final FontWeight fontWeight;
  final double letterSpacing;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? AppColors.primaryDark;
    final effectiveOutlineColor = outlineColor ??
        (effectiveTextColor == AppColors.primaryDark && AppColors.isDark
            ? Colors.black
            : (AppColors.isDark ? Colors.black : AppColors.primaryDark));
    final effectiveShadowColor = shadowColor ??
        (AppColors.isDark
            ? Colors.black.withValues(alpha: 0.5)
            : AppColors.primaryDark.withValues(alpha: 0.18));

    return Stack(
      children: [
        // 1. Solid Offset Shadow Layer (Comic Drop Shadow)
        Transform.translate(
          offset: const Offset(2.5, 2.5),
          child: Text(
            text,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            style: GoogleFonts.fredoka(
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              color: effectiveShadowColor,
            ),
          ),
        ),

        // 2. Comic Ink Outline Layer (Teknik Stroke Border)
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          style: GoogleFonts.fredoka(
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.2
              ..color = effectiveOutlineColor,
          ),
        ),

        // 3. Foreground Text Layer (Warna Utama/Fill)
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          style: GoogleFonts.fredoka(
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            color: effectiveTextColor,
          ),
        ),
      ],
    );
  }
}
