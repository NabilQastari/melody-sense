import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: disabled ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(challenge.icon, color: AppColors.primaryDark, size: 22),
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
                              style: const TextStyle(
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
                      const SizedBox(height: 4),
                      Text(
                        challenge.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryDark.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}