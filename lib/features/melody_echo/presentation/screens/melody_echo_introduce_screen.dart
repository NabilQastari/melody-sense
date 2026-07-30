import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/pattern_painters.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/virtual_piano.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';

class MelodyEchoIntroduceScreen extends ConsumerStatefulWidget {
  const MelodyEchoIntroduceScreen({super.key});

  @override
  ConsumerState<MelodyEchoIntroduceScreen> createState() =>
      _MelodyEchoIntroduceScreenState();
}

class _MelodyEchoIntroduceScreenState
    extends ConsumerState<MelodyEchoIntroduceScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Interactive module state
  final List<String> _targetSequence = ['C4', 'E4', 'G4'];
  final List<String> _userInputs = [];
  bool _isPlayingDemo = false;
  bool _isSuccess = false;
  String? _activeHighlightNote;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _playDemoSequence() async {
    if (_isPlayingDemo) return;
    setState(() {
      _isPlayingDemo = true;
      _userInputs.clear();
      _isSuccess = false;
    });

    final audio = ref.read(audioServiceProvider);
    for (final note in _targetSequence) {
      setState(() => _activeHighlightNote = note);
      await audio.playNote(note);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (mounted) {
      setState(() {
        _activeHighlightNote = null;
        _isPlayingDemo = false;
      });
    }
  }

  void _handleUserTap(String note) {
    if (_isPlayingDemo || _isSuccess) return;

    final audio = ref.read(audioServiceProvider);
    audio.playNote(note);

    final nextIndex = _userInputs.length;
    if (nextIndex < _targetSequence.length && note == _targetSequence[nextIndex]) {
      setState(() {
        _userInputs.add(note);
        if (_userInputs.length == _targetSequence.length) {
          _isSuccess = true;
        }
      });
    } else {
      setState(() {
        _userInputs.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nada salah! Coba dengarkan lagi.'),
          duration: Duration(milliseconds: 1000),
        ),
      );
    }
  }

  void _finishIntroduce() {
    ref
        .read(educationProgressProvider.notifier)
        .markIntroduceCompleted('melody_echo');
    Navigator.of(context).pop();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishIntroduce();
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
                    title: 'MELODY ECHO',
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
                onPageChanged: (idx) => setState(() => _currentPage = idx),
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
                    Icons.hearing_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const WhiskerBannerHeader(
                  title: 'KONSEP MELODY ECHO',
                  fontSize: 15,
                  rotateAngle: -0.03,
                ),
                const SizedBox(height: 14),
                Text(
                  'Melody Echo melatih memori telingamu (auditory memory) untuk mengingat urutan nada melodi singkat dan memainkannya kembali secara persis.',
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
                  icon: Icons.repeat_rounded,
                  color: Colors.purple.shade700,
                  title: 'DENGERKAN DAHULU, BARU GEMA',
                  description:
                      'Aplikasi akan memperdengarkan sekuens nada terlebih dahulu. Setelah selesai, giliranmu menekan tuts yang sesuai secara berurutan.',
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
                  backgroundColor: AppColors.primaryDark,
                  borderColor: AppColors.primaryDark,
                  borderWidth: 2.5,
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const WhiskerBannerHeader(
                  title: 'TINGKAT KESULITAN BERTINGKAT',
                  fontSize: 15,
                  rotateAngle: -0.03,
                ),
                const SizedBox(height: 14),
                Text(
                  'Latihan dimulai dari 3 nada sederhana hingga mencapai 7 nada berturut-turut pada ronde akhir.',
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
                  icon: Icons.psychology_rounded,
                  color: Colors.green.shade700,
                  title: 'FOKUS & KONSENTRASI',
                  description:
                      'Dengarkan pola interval antar-nada. Mengetahui posisi pitch naik-turun akan mempermudah mengingat urutan melodi.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          const WhiskerBannerHeader(
            title: 'MODUL SIMULASI MELODY ECHO',
            fontSize: 15,
            rotateAngle: -0.03,
          ),
          const SizedBox(height: 8),
          Text(
            'Dengarkan contoh melodi 3 nada, lalu tekan tuts piano untuk mengulanginya.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // Play Demo Button
          GestureDetector(
            onTap: _playDemoSequence,
            child: StickerBadge(
              rotateAngle: -0.03,
              backgroundColor: AppColors.accent,
              borderColor: AppColors.primaryDark,
              borderWidth: 2.2,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isPlayingDemo ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isPlayingDemo ? 'MEMUTAR MELODI...' : 'PUTAR MELODI CONTOH (C4 - E4 - G4)',
                    style: GoogleFonts.fredoka(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Progress display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_targetSequence.length, (idx) {
              final isFilled = idx < _userInputs.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isFilled ? Colors.green.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isFilled ? Colors.green.shade700 : AppColors.primaryDark,
                    width: 2.0,
                  ),
                ),
                child: Text(
                  isFilled ? _userInputs[idx] : '?',
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isFilled ? Colors.green.shade900 : AppColors.primaryDark,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          if (_isSuccess)
            StickerBadge(
              rotateAngle: 0.02,
              backgroundColor: Colors.green.shade600,
              borderColor: AppColors.primaryDark,
              borderWidth: 2.0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'BERHASIL MENGULANGI MELODI!',
                style: GoogleFonts.fredoka(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Mini Virtual Piano
          SizedBox(
            height: 140,
            child: VirtualPiano(
              activeNote: _activeHighlightNote,
              onNotePressed: _handleUserTap,
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
