import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/sticker_badge.dart';
import '../../../../core/widgets/torn_paper_card.dart';
import '../models/challenge_info.dart';
import 'difficulty_badge.dart';

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  final ChallengeInfo challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool disabled = !challenge.enabled;

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: TornPaperCard(
          backgroundColor: AppColors.surfaceWhite,
          shadowColor: AppColors.surfaceTint,
          borderWidth: 2.6,
          tornPosition: TornEdgePosition.bottom,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              StickerBadge(
                rotateAngle: -0.05,
                backgroundColor: AppColors.surfaceTint,
                borderColor: AppColors.primaryDark,
                borderWidth: 2.2,
                padding: const EdgeInsets.all(10),
                child: Icon(challenge.icon, color: AppColors.primaryDark, size: 24),
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
                            challenge.title,
                            style: GoogleFonts.fredoka(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        DifficultyBadge(
                          difficulty: challenge.difficulty,
                          comingSoon: disabled,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      challenge.subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.primaryDark.withValues(alpha: 0.75),
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