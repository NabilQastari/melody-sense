import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/pattern_painters.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';

class IntervalTrainingIntroduceScreen extends ConsumerStatefulWidget {
  const IntervalTrainingIntroduceScreen({super.key});

  @override
  ConsumerState<IntervalTrainingIntroduceScreen> createState() =>
      _IntervalTrainingIntroduceScreenState();
}

class _IntervalTrainingIntroduceScreenState
    extends ConsumerState<IntervalTrainingIntroduceScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedIntervalName = 'Major 3rd';
  bool _isPlayingSample = false;

  final Map<String, List<String>> _intervalSamples = {
    'Minor 2nd': ['C4', 'C#4'],
    'Major 2nd': ['C4', 'D4'],
    'Minor 3rd': ['D4', 'F4'],
    'Major 3rd': ['C4', 'E4'],
    'Perfect 4th': ['C4', 'F4'],
    'Perfect 5th': ['C4', 'G4'],
    'Major 6th': ['C4', 'A4'],
    'Major 7th': ['C4', 'B4'],
    'Octave': ['C4', 'C5'],
  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _playSample(String intervalName) async {
    if (_isPlayingSample) return;
    setState(() {
      _selectedIntervalName = intervalName;
      _isPlayingSample = true;
    });

    final notes = _intervalSamples[intervalName] ?? ['C4', 'E4'];
    final audio = ref.read(audioServiceProvider);

    await audio.playSequence(
      notes,
      gap: const Duration(milliseconds: 500),
    );

    if (mounted) {
      setState(() => _isPlayingSample = false);
    }
  }

  Future<void> _completeIntroduce() async {
    await ref
        .read(educationProgressProvider.notifier)
        .markIntroduceCompleted('interval_training');
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
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                    title: 'INTERVAL TRAINING',
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
                      backgroundColor: AppColors.primaryDark,
                      borderColor: AppColors.primaryDark,
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

  // Slide 1: Konsep Jarak Nada
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
                    Icons.straighten_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const WhiskerBannerHeader(
                  title: 'KONSEP JARAK NADA (INTERVAL)',
                  fontSize: 15,
                  rotateAngle: -0.03,
                ),
                const SizedBox(height: 14),
                Text(
                  'Interval adalah jarak tinggi-rendah pitch antara dua nada yang dibunyikan secara berurutan atau bersamaan.',
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
                  icon: Icons.unfold_more_rounded,
                  color: Colors.blue.shade700,
                  title: 'SEMITONE (JARAK TERDEKAT)',
                  description:
                      'Satuan ukur terkecil jarak nada di piano adalah Semitone (setengah langkah). Misalnya dari C4 ke C#4.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Slide 2: Jenis Interval Musik
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
                  backgroundColor: AppColors.primaryDark,
                  borderColor: AppColors.primaryDark,
                  borderWidth: 2.5,
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const WhiskerBannerHeader(
                  title: 'JENIS INTERVAL UTAMA',
                  fontSize: 16,
                  rotateAngle: -0.03,
                ),
                const SizedBox(height: 14),
                Text(
                  'Setiap kombinasi jarak nada memberikan nuansa karakter yang unik (riang, ceria, sedih, atau tegang).',
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
                  icon: Icons.sentiment_satisfied_alt_rounded,
                  color: Colors.green.shade700,
                  title: 'MAJOR & MINOR',
                  description:
                      'Major 3rd (C4-E4) memberi nuansa ceria dan terang, sedangkan Minor 3rd (D4-F4) memberi nuansa teduh dan sedih.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Slide 3: Modul Contoh Sampel Interval Interaktif
  Widget _buildSlide3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          const WhiskerBannerHeader(
            title: 'DENGARKAN CONTOH INTERVAL',
            fontSize: 15,
            rotateAngle: -0.03,
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih interval di bawah untuk mendengarkan bunyinya.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _intervalSamples.keys.map((intervalName) {
              final isSelected = _selectedIntervalName == intervalName;

              return GestureDetector(
                onTap: () => _playSample(intervalName),
                child: StickerBadge(
                  rotateAngle: isSelected ? -0.04 : 0.02,
                  backgroundColor: isSelected ? AppColors.accent : Colors.white,
                  borderColor: AppColors.primaryDark,
                  borderWidth: 2.0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        intervalName,
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isSelected && _isPlayingSample
                            ? Icons.volume_up_rounded
                            : Icons.play_arrow_rounded,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.primaryDark,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
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
