import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/sticker_badge.dart';
import '../models/challenge_info.dart';

class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.comingSoon = false,
  });

  final ChallengeDifficulty difficulty;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    final String label = comingSoon ? 'SOON' : difficulty.label;

    return StickerBadge(
      rotateAngle: 0.04,
      backgroundColor: comingSoon ? Colors.grey.shade200 : AppColors.surfaceTint,
      borderColor: AppColors.primaryDark,
      borderWidth: 1.8,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      child: Text(
        label,
        style: GoogleFonts.fredoka(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: comingSoon ? Colors.grey.shade700 : AppColors.primaryDark,
        ),
      ),
    );
  }
}