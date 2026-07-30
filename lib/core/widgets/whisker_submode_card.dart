import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';

/// Shared Whisker-styled submode card used across all submode picker screens.
/// Replaces the plain white rounded card with Design System v3 elements.
class WhiskerSubmodeCard extends StatelessWidget {
  const WhiskerSubmodeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isEnabled,
    this.isCompleted = false,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isEnabled;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.55,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: TornPaperCard(
          backgroundColor: AppColors.surfaceWhite,
          shadowColor: AppColors.surfaceTint,
          borderWidth: 2.6,
          tornPosition: TornEdgePosition.bottom,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              StickerBadge(
                rotateAngle: -0.05,
                backgroundColor: isEnabled
                    ? iconColor.withValues(alpha: 0.15)
                    : AppColors.surfaceTint,
                borderColor: AppColors.primaryDark,
                borderWidth: 2.2,
                padding: const EdgeInsets.all(10),
                child: Icon(
                  isEnabled ? icon : Icons.lock_outline_rounded,
                  color: isEnabled ? iconColor : AppColors.primaryDark.withValues(alpha: 0.4),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.fredoka(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          StickerBadge(
                            rotateAngle: 0.05,
                            backgroundColor: Colors.green.shade100,
                            borderColor: Colors.green.shade700,
                            borderWidth: 1.8,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: Colors.green.shade700, size: 10),
                                const SizedBox(width: 3),
                                Text(
                                  'SELESAI',
                                  style: GoogleFonts.fredoka(
                                    color: Colors.green.shade700,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        color: AppColors.primaryDark.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared Whisker-styled app bar for submode picker screens.
class WhiskerSubmodeAppBar extends StatelessWidget {
  const WhiskerSubmodeAppBar({
    super.key,
    required this.title,
    required this.featureName,
    required this.description,
  });

  final String title;
  final String featureName;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App Bar Row
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryDark, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.15),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.arrow_back_rounded,
                      size: 20, color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(width: 12),
              WhiskerBannerHeader(
                title: title,
                fontSize: 15,
                rotateAngle: -0.03,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
            ],
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WhiskerBannerHeader(
                title: featureName,
                fontSize: 18,
                rotateAngle: -0.04,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: AppColors.primaryDark.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
