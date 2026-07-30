import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/whisker_submode_card.dart';

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
            const WhiskerSubmodeAppBar(
              title: 'SUBMODE LATIHAN',
              featureName: 'RHYTHM MATCH',
              description:
                  'Pilih mode latihan ritme lagu yang ingin kamu mainkan.',
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  // 1. Introduce Card
                  WhiskerSubmodeCard(
                    title: 'Introduce (Perkenalan)',
                    subtitle: 'Pengenalan ritme lagu & modul interaktif (3 Slide)',
                    icon: Icons.menu_book_rounded,
                    iconColor: Colors.orangeAccent,
                    isEnabled: true,
                    isCompleted: hasCompletedIntroduce,
                    onTap: () => _onSelectIntroduce(context),
                  ),
                  const SizedBox(height: 14),

                  // 2. Start Training Card
                  WhiskerSubmodeCard(
                    title: 'Start Training',
                    subtitle: 'Mainkan lagu penuh (Twinkle Star, Happy Birthday, Für Elise)',
                    icon: Icons.play_arrow_rounded,
                    iconColor: AppColors.accent,
                    isEnabled: hasCompletedIntroduce,
                    onTap: () => _onSelectSubmode(
                      context,
                      hasCompletedIntroduce,
                      PracticeSubmode.practice,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Guided Practice Card
                  WhiskerSubmodeCard(
                    title: 'Guided Practice',
                    subtitle: 'Latihan lagu terbimbing dengan petunjuk tuts menyala',
                    icon: Icons.gps_fixed_rounded,
                    iconColor: Colors.green,
                    isEnabled: hasCompletedIntroduce,
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
