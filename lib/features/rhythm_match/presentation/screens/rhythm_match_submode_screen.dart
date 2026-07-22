import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import 'package:melody_sense/core/theme/app_colors.dart';

import 'rhythm_match_introduce_screen.dart';
import 'rhythm_match_song_select_screen.dart';

class RhythmMatchSubmodeScreen extends ConsumerWidget {
  const RhythmMatchSubmodeScreen({super.key});

  void _onSelectIntroduce(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RhythmMatchIntroduceScreen(),
      ),
    );
  }

  void _onSelectSubmode(
    BuildContext context,
    bool isUnlocked,
    PracticeSubmode submode,
  ) {
    if (!isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selesaikan "Introduce" terlebih dahulu untuk membuka mode ini.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RhythmMatchSongSelectScreen(submode: submode),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCompletedIntroduce =
        ref.watch(educationProgressProvider)['rhythm_match'] ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTint.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 20, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Rhythm Match',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  Text(
                    'Pilih mode latihan ritme lagu yang ingin kamu mainkan.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryDark.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. Introduce Card
                  _SubmodeCard(
                    title: 'Introduce',
                    subtitle: 'Pengenalan ritme lagu & modul interaktif (3 Slide)',
                    icon: Icons.menu_book_rounded,
                    accentColor: Colors.orangeAccent,
                    isUnlocked: true,
                    onTap: () => _onSelectIntroduce(context),
                  ),
                  const SizedBox(height: 14),

                  // 2. Start Training Card (Song Play)
                  _SubmodeCard(
                    title: 'Start Training',
                    subtitle: 'Mainkan lagu penuh (Twinkle Star, Happy Birthday, Für Elise)',
                    icon: Icons.play_arrow_rounded,
                    accentColor: AppColors.accent,
                    isUnlocked: hasCompletedIntroduce,
                    onTap: () => _onSelectSubmode(
                      context,
                      hasCompletedIntroduce,
                      PracticeSubmode.practice,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Guided Practice Card
                  _SubmodeCard(
                    title: 'Guided Practice',
                    subtitle: 'Latihan lagu terbimbing dengan petunjuk tuts menyala',
                    icon: Icons.gps_fixed_rounded,
                    accentColor: Colors.green,
                    isUnlocked: hasCompletedIntroduce,
                    onTap: () => _onSelectSubmode(
                      context,
                      hasCompletedIntroduce,
                      PracticeSubmode.guided,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmodeCard extends StatelessWidget {
  const _SubmodeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.isUnlocked,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isUnlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppColors.surfaceWhite
              : AppColors.surfaceWhite.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
          border: Border.all(
            color: isUnlocked
                ? accentColor.withValues(alpha: 0.3)
                : AppColors.surfaceTint.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? accentColor.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isUnlocked ? accentColor : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isUnlocked
                          ? AppColors.primaryDark
                          : AppColors.primaryDark.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isUnlocked
                          ? AppColors.primaryDark.withValues(alpha: 0.6)
                          : AppColors.primaryDark.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isUnlocked ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
              color: isUnlocked
                  ? AppColors.primaryDark.withValues(alpha: 0.4)
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
