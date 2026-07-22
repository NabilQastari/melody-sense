import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';

class RhythmMatchIntroduceScreen extends ConsumerStatefulWidget {
  const RhythmMatchIntroduceScreen({super.key});

  @override
  ConsumerState<RhythmMatchIntroduceScreen> createState() =>
      _RhythmMatchIntroduceScreenState();
}

class _RhythmMatchIntroduceScreenState
    extends ConsumerState<RhythmMatchIntroduceScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // State untuk Slide 3 (Interactive Module)
  int _demoStep = 0;
  final List<String> _demoNotes = ['C4', 'C4', 'G4', 'G4'];
  String? _demoPlayingNote;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _playDemoNote(String note) {
    setState(() => _demoPlayingNote = note);
    ref.read(audioServiceProvider).playNote(note);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _demoPlayingNote = null;
          _demoStep = (_demoStep + 1) % _demoNotes.length;
        });
      }
    });
  }

  Future<void> _completeIntroduce() async {
    await ref
        .read(educationProgressProvider.notifier)
        .markIntroduceCompleted('rhythm_match');
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeIntroduce();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Text(
                    'Slide ${_currentPage + 1} dari 3',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark.withValues(alpha: 0.6),
                    ),
                  ),
                  if (_currentPage < 2)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          2,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // ── Slide Content (PageView) ──
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildSlide1(),
                  _buildSlide2(),
                  _buildSlide3(),
                ],
              ),
            ),

            // ── Bottom Navigation Controls ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Dot indicators
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryDark
                              : AppColors.surfaceTint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  // Action button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: AppColors.surfaceWhite,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == 2
                              ? 'Selesai & Mulai Latihan'
                              : 'Lanjut',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == 2
                              ? Icons.check_circle_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
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

  // Slide 1: Apa itu Ritme & Melodi Lagu
  Widget _buildSlide1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer_rounded,
              size: 48,
              color: Colors.orangeAccent,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          const Text(
            'Bermain Lagu & Ritme',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 14),
          Text(
            'Di mode Rhythm Match, kamu akan memainkan lagu musik nyata (seperti Twinkle Star, Happy Birthday, dan Für Elise) dari awal sampai akhir.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          _buildInfoCard(
            icon: Icons.music_note_rounded,
            color: Colors.orangeAccent,
            title: 'Bermain Bebas Tanpa Timer Paksaan',
            description:
                'Tidak ada timer yang melompat sendiri jika terlambat. Kamu bisa memainkan nada demi nada sesuai kecepatan jemarimu.',
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  // Slide 2: Penilaian Akurasi & Waktu
  Widget _buildSlide2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              size: 48,
              color: Colors.amber,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          const Text(
            'Akurasi & Waktu Terbaik',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 14),
          Text(
            'Dua hal utama yang dinilai di akhir lagu adalah seberapa tepat nada yang kamu tekan dan seberapa cepat kamu menyelesaikan seluruh lagu.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          _buildInfoCard(
            icon: Icons.emoji_events_rounded,
            color: Colors.amber,
            title: 'Rating Bintang (1–3 ⭐)',
            description:
                'Raih Akurasi nada 90%+ untuk mendapatkan 3 Bintang sempurna ⭐⭐⭐ serta bonus XP tertinggi!',
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  // Slide 3: Modul Interaktif
  Widget _buildSlide3() {
    final targetNote = _demoNotes[_demoStep];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.touch_app_rounded,
                    color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                'Coba 4 Ketukan Intro',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 350.ms),
          const SizedBox(height: 6),
          Text(
            'Tekan tuts nada yang menyala di bawah untuk mencoba 4 nada awal Twinkle Star.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryDark.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 24),

          // Display Note Step
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Nada Ke-${_demoStep + 1} dari 4',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  targetNote,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < _demoNotes.length; i++) ...[
                GestureDetector(
                  onTap: () => _playDemoNote(_demoNotes[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: (_demoStep == i || _demoPlayingNote == _demoNotes[i])
                          ? AppColors.accent
                          : AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _demoStep == i
                            ? AppColors.accent
                            : AppColors.surfaceTint,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _demoNotes[i],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _demoStep == i
                            ? AppColors.surfaceWhite
                            : AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
                if (i < _demoNotes.length - 1) const SizedBox(width: 10),
              ],
            ],
          ).animate().fadeIn(duration: 450.ms),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.primaryDark.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
