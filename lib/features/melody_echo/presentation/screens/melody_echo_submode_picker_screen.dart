import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/whisker_submode_card.dart';

import 'melody_echo_introduce_screen.dart';
import 'melody_echo_screen.dart';

class MelodyEchoSubmodePickerScreen extends ConsumerWidget {
  const MelodyEchoSubmodePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(educationProgressProvider);
    final isIntroduceRead = progress['melody_echo'] ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const WhiskerSubmodeAppBar(
              title: 'SUBMODE LATIHAN',
              featureName: 'MELODY ECHO',
              description:
                  'Dengarkan urutan melodi, lalu ulangi kembali nada demi nada.',
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  WhiskerSubmodeCard(
                    title: 'Introduce (Perkenalan)',
                    subtitle:
                        'Pelajari cara mendengarkan, mengulangi melodi, dan coba contoh 3 nada.',
                    icon: Icons.menu_book_rounded,
                    iconColor: Colors.blueAccent,
                    isEnabled: true,
                    isCompleted: isIntroduceRead,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MelodyEchoIntroduceScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  WhiskerSubmodeCard(
                    title: 'Start Training (8 Rounds)',
                    subtitle:
                        'Uji daya ingat telingamu mengulangi melodi bertahap dari 3 hingga 7 nada. Sesi memiliki nyawa.',
                    icon: Icons.play_arrow_rounded,
                    iconColor: Colors.green,
                    isEnabled: isIntroduceRead,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MelodyEchoScreen(
                          submode: PracticeSubmode.practice,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  WhiskerSubmodeCard(
                    title: 'Guided Practice',
                    subtitle:
                        'Latihan terbimbing dengan petunjuk visual jika kamu kesulitan mengingat nada berikutnya. Tanpa nyawa.',
                    icon: Icons.explore_rounded,
                    iconColor: Colors.purpleAccent,
                    isEnabled: isIntroduceRead,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MelodyEchoScreen(
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
