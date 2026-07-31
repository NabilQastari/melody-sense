import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:melody_sense/core/domain/entities/operating_mode.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import 'package:melody_sense/core/providers/operating_mode_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/pattern_painters.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentSlide();
    });
  }

  void _speakCurrentSlide() {
    final mode = ref.read(operatingModeProvider);
    final isSenseMode = mode == AppOperatingMode.sense || ref.read(senseModeProvider);
    if (!isSenseMode) return;

    final tts = ref.read(ttsServiceProvider);
    switch (_currentPage) {
      case 0:
        tts.speak(
          'Slide 1 dari 3. Apa itu Rhythm Match. Mode ini melatih ketepatan waktu dan ritme saat memainkan lagu populer.',
          force: true,
        );
        break;
      case 1:
        tts.speak(
          'Slide 2 dari 3. Sistem penilaian ritme. Tekan tuts sesuai tempo lagu untuk memperoleh predikat Perfect atau Good.',
          force: true,
        );
        break;
      case 2:
        tts.speak(
          'Slide 3 dari 3. Modul latihan tempo. Tekan tombol nada secara ritmis mengikuti ketukan lagu Twinkle Twinkle Little Star.',
          force: true,
        );
        break;
    }
  }

  @override
  void dispose() {
    ref.read(ttsServiceProvider).stop();
    _pageController.dispose();
    super.dispose();
  }

  void _playDemoNote(String note) {
    ref.read(audioServiceProvider).playNote(note);

    final mode = ref.read(operatingModeProvider);
    final isSenseMode = mode == AppOperatingMode.sense || ref.read(senseModeProvider);
    if (isSenseMode) {
      final spokenNote = ref.read(ttsServiceProvider).formatNoteForSpeech(note);
      ref.read(ttsServiceProvider).speak(spokenNote, force: true);
    }

    setState(() {
      _demoStep = (_demoStep + 1) % _demoNotes.length;
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
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryDark, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.15),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 20, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const WhiskerBannerHeader(
                    title: 'RHYTHM MATCH',
                    fontSize: 14,
                    rotateAngle: -0.03,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  const Spacer(),
                  StickerBadge(
                    rotateAngle: 0.03,
                    backgroundColor: AppColors.surfaceTint,
                    borderColor: AppColors.primaryDark,
                    borderWidth: 1.8,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'SLIDE ${_currentPage + 1}/3',
                      style: GoogleFonts.fredoka(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Slide PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                  _speakCurrentSlide();
                },
                children: [
                  _buildSlide1(),
                  _buildSlide2(),
                  _buildSlide3(),
                ],
              ),
            ),

            // Bottom Navigation Controls
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border(
                  top: BorderSide(color: AppColors.primaryDark, width: 2.2),
                ),
              ),
              child: Row(
                children: [
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
                          border: Border.all(color: AppColors.primaryDark, width: 1.2),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _nextPage,
                    child: StickerBadge(
                      rotateAngle: -0.02,
                      backgroundColor: AppColors.accent,
                      borderColor: AppColors.isDark ? Colors.black : AppColors.primaryDark,
                      borderWidth: 2.2,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == 2
                                ? 'SELESAI & MULAI LATIHAN'
                                : 'LANJUT',
                            style: GoogleFonts.fredoka(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == 2
                                ? Icons.check_circle_rounded
                                : Icons.arrow_forward_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
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

  Widget _buildSlide1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: TornPaperCard(
        backgroundColor: AppColors.surfaceWhite,
        shadowColor: AppColors.surfaceTint,
        borderWidth: 2.8,
        tornPosition: TornEdgePosition.both,
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: 10,
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: HalftonePatternPainter(
                  color: AppColors.surfaceTint,
                  opacity: 0.25,
                ),
              ),
            ),
            Column(
              children: [
                StickerBadge(
                  rotateAngle: -0.05,
                  backgroundColor: AppColors.accent,
                  borderColor: AppColors.primaryDark,
                  borderWidth: 2.5,
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.timer_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const WhiskerBannerHeader(
                  title: 'KONSEP RHYTHM MATCH',
                  fontSize: 15,
                  rotateAngle: -0.03,
                ),
                const SizedBox(height: 14),
                Text(
                  'Rhythm Match melatih ketepatan tempo dan ritme mengetuk nada sesuai irama lagu nyata.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.primaryDark.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  icon: Icons.speed_rounded,
                  color: Colors.orange.shade800,
                  title: 'KETEPATAN WAKTU (TEMPO)',
                  description:
                      'Ketuk tuts tepat saat balok irama mencapai area target untuk mendapatkan penilaian Perfect atau Great.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: TornPaperCard(
        backgroundColor: AppColors.surfaceWhite,
        shadowColor: AppColors.surfaceTint,
        borderWidth: 2.8,
        tornPosition: TornEdgePosition.both,
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: 10,
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: HalftonePatternPainter(
                  color: AppColors.surfaceTint,
                  opacity: 0.25,
                ),
              ),
            ),
            Column(
              children: [
                StickerBadge(
                  rotateAngle: 0.05,
                  backgroundColor: AppColors.accent,
                  borderColor: AppColors.isDark ? Colors.black : AppColors.primaryDark,
                  borderWidth: 2.5,
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.music_video_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const WhiskerBannerHeader(
                  title: 'MEMAINKAN LAGU POPULER',
                  fontSize: 15,
                  rotateAngle: -0.03,
                ),
                const SizedBox(height: 14),
                Text(
                  'Kamu akan memainkan lagu populer seperti Twinkle Twinkle Little Star, Happy Birthday, dan Für Elise.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.primaryDark.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  icon: Icons.star_rounded,
                  color: Colors.amber.shade800,
                  title: 'SKOR & KANOMAN COMBO',
                  description:
                      'Pertahankan ketukan tanpa luput (Miss) untuk membangun Combo streak dan meraih skor tertinggi.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide3() {
    final currentTargetNote = _demoNotes[_demoStep];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          const WhiskerBannerHeader(
            title: 'SIMULASI KETUKAN RITME',
            fontSize: 15,
            rotateAngle: -0.03,
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol nada target di bawah untuk mengetuk irama Twinkle Star (C4 - C4 - G4 - G4).',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Note indicator steps
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_demoNotes.length, (idx) {
              final isCurrentStep = idx == _demoStep;
              final isPastStep = idx < _demoStep;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrentStep
                      ? AppColors.accent
                      : (isPastStep ? Colors.green.shade100 : AppColors.surfaceWhite),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrentStep
                        ? AppColors.primaryDark
                        : (isPastStep ? Colors.green.shade700 : AppColors.primaryDark),
                    width: 2.2,
                  ),
                ),
                child: Text(
                  _demoNotes[idx],
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isCurrentStep
                        ? Colors.white
                        : (isPastStep ? Colors.green.shade900 : AppColors.primaryDark),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Interactive tap button
          GestureDetector(
            onTap: () => _playDemoNote(currentTargetNote),
            child: StickerBadge(
              rotateAngle: -0.03,
              backgroundColor: AppColors.accent,
              borderColor: AppColors.primaryDark,
              borderWidth: 2.6,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Column(
                children: [
                  const Icon(Icons.touch_app_rounded, color: Colors.white, size: 28),
                  const SizedBox(height: 6),
                  Text(
                    'KETUK NADA: $currentTargetNote',
                    style: GoogleFonts.fredoka(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryDark, width: 2.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StickerBadge(
            rotateAngle: -0.04,
            backgroundColor: color,
            borderColor: AppColors.primaryDark,
            borderWidth: 1.8,
            padding: const EdgeInsets.all(6),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.fredoka(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark.withValues(alpha: 0.75),
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
