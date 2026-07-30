import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/whisker_submode_card.dart';

import 'note_recognition_introduce_screen.dart';
import 'note_recognition_screen.dart';

class NoteRecognitionSubmodePickerScreen extends ConsumerWidget {
  const NoteRecognitionSubmodePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(educationProgressProvider);
    final isIntroduceRead = progress['note_recognition'] ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const WhiskerSubmodeAppBar(
              title: 'SUBMODE LATIHAN',
              featureName: 'NOTE RECOGNITION',
              description:
                  'Pahami materi dasarnya terlebih dahulu untuk membuka latihan penuh.',
            ),

            // ── Submode List ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  // 1. Introduce Submode
                  WhiskerSubmodeCard(
                    title: 'Introduce (Perkenalan)',
                    subtitle:
                        'Pelajari teori dasar notasi ilmiah, oktaf, serta dengarkan contoh nada secara interaktif.',
                    icon: Icons.menu_book_rounded,
                    iconColor: Colors.blueAccent,
                    isEnabled: true,
                    isCompleted: isIntroduceRead,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NoteRecognitionIntroduceScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 2. Start Practice Submode
                  WhiskerSubmodeCard(
                    title: 'Start Training (10 Rounds)',
                    subtitle:
                        'Uji kepekaan telingamu menebak nada target dengan piano virtual. Sesi memiliki nyawa.',
                    icon: Icons.play_arrow_rounded,
                    iconColor: Colors.green,
                    isEnabled: isIntroduceRead,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NoteRecognitionScreen(
                          submode: PracticeSubmode.practice,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 3. Guided Practice Submode
                  WhiskerSubmodeCard(
                    title: 'Guided Practice',
                    subtitle:
                        'Latihan terbimbing dengan petunjuk otomatis yang muncul di piano jika kamu kebingungan. Tanpa nyawa.',
                    icon: Icons.explore_rounded,
                    iconColor: Colors.purpleAccent,
                    isEnabled: isIntroduceRead,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NoteRecognitionScreen(
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
