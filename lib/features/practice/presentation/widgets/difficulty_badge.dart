import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
    final String label = comingSoon ? 'COMING SOON' : difficulty.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: comingSoon ? const Color(0xFFE3E3E3) : AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: comingSoon ? const Color(0xFF8A8A8A) : AppColors.primaryDark,
        ),
      ),
    );
  }
}