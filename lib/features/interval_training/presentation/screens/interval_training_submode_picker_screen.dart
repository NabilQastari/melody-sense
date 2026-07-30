import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/whisker_submode_card.dart';

import 'interval_training_introduce_screen.dart';
import 'interval_training_screen.dart';

class IntervalTrainingSubmodePickerScreen extends ConsumerWidget {
  const IntervalTrainingSubmodePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(educationProgressProvider);
    final isIntroduceRead = progress['interval_training'] ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const WhiskerSubmodeAppBar(
              title: 'SUBMODE LATIHAN',
              featureName: 'INTERVAL TRAINING',
              description:
                  'Pahami materi dasarnya terlebih dahulu untuk membuka latihan penuh.',
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  WhiskerSubmodeCard(
                    title: 'Introduce (Perkenalan)',
                    subtitle:
                        'Pelajari teori dasar jarak nada, semitone, serta dengarkan contoh interval secara interaktif.',
                    icon: Icons.menu_book_rounded,
                    iconColor: Colors.blueAccent,
                    isEnabled: true,
                    isCompleted: isIntroduceRead,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const IntervalTrainingIntroduceScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  WhiskerSubmodeCard(
                    title: 'Start Training (10 Rounds)',
                    subtitle:
                        'Uji pendengaranmu menebak nada kedua dari interval target. Sesi memiliki nyawa.',
                    icon: Icons.play_arrow_rounded,
                    iconColor: Colors.green,
                    isEnabled: isIntroduceRead,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const IntervalTrainingScreen(
                          submode: PracticeSubmode.practice,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  WhiskerSubmodeCard(
                    title: 'Guided Practice',
                    subtitle:
                        'Latihan terbimbing dengan petunjuk 2 tahap (Root & Target note) jika kamu kebingungan. Tanpa nyawa.',
                    icon: Icons.explore_rounded,
                    iconColor: Colors.purpleAccent,
                    isEnabled: isIntroduceRead,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const IntervalTrainingScreen(
                          submode: PracticeSubmode.guided,
                        ),
                      ),
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
