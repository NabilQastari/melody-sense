import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';

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
            // ── App Bar ──
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
                    'Pilih Submode Latihan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),

            // ── Header Text ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Note Recognition',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pahami materi dasarnya terlebih dahulu untuk membuka latihan penuh.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.primaryDark.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0),

            // ── Submode List ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  // 1. Introduce Submode
                  _buildSubmodeCard(
                    context,
                    title: '📖 Introduce (Perkenalan)',
                    subtitle: 'Pelajari teori dasar notasi ilmiah, oktaf, serta dengarkan contoh nada secara interaktif.',
                    icon: Icons.menu_book_rounded,
                    iconColor: Colors.blueAccent,
                    isEnabled: true,
                    isCompleted: isIntroduceRead,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NoteRecognitionIntroduceScreen(),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0),

                  const SizedBox(height: 14),

                  // 2. Start Practice Submode
                  _buildSubmodeCard(
                    context,
                    title: '🎮 Start Training (10 Rounds)',
                    subtitle: 'Uji kepekaan telingamu menebak nada target dengan piano virtual. Sesi memiliki nyawa.',
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
                  ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.08, end: 0),



                  const SizedBox(height: 14),

                  // 4. Guided Practice Submode
                  _buildSubmodeCard(
                    context,
                    title: '🎯 Guided Practice',
                    subtitle: 'Latihan terbimbing dengan petunjuk otomatis yang muncul di piano jika kamu kebingungan. Tanpa nyawa.',
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
                  ).animate().fadeIn(duration: 550.ms).slideY(begin: 0.08, end: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmodeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isEnabled,
    bool isCompleted = false,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: isEnabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isEnabled ? iconColor.withValues(alpha: 0.1) : AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isEnabled ? icon : Icons.lock_outline_rounded,
                      color: isEnabled ? iconColor : AppColors.primaryDark.withValues(alpha: 0.4),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green, width: 1),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.green, size: 10),
                                    SizedBox(width: 4),
                                    Text(
                                      'Selesai',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.4,
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
      ),
    );
  }
}
