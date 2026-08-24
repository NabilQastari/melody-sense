import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melody_sense/core/domain/entities/operating_mode.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import 'package:melody_sense/core/providers/note_notation_provider.dart';
import 'package:melody_sense/core/providers/operating_mode_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/pattern_painters.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';

class NoteRecognitionIntroduceScreen extends ConsumerStatefulWidget {
  const NoteRecognitionIntroduceScreen({super.key});

  @override
  ConsumerState<NoteRecognitionIntroduceScreen> createState() =>
      _NoteRecognitionIntroduceScreenState();
}

class _NoteRecognitionIntroduceScreenState
    extends ConsumerState<NoteRecognitionIntroduceScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _playingNote;

  final List<Map<String, String>> _notesInfo = [
    {'note': 'B3', 'solfege': 'Si (Oktaf 3)', 'desc': 'Nada terendah di mode ini.'},
    {'note': 'C4', 'solfege': 'Do (Middle C)', 'desc': 'Do tengah, standar musik dasar.'},
    {'note': 'C#4', 'solfege': 'Do# / Reb', 'desc': 'Nada kromatik (tuts hitam) antara C4 & D4.'},
    {'note': 'D4', 'solfege': 'Re', 'desc': 'Satu langkah di atas C4.'},
    {'note': 'D#4', 'solfege': 'Re# / Mib', 'desc': 'Nada kromatik antara D4 & E4.'},
    {'note': 'E4', 'solfege': 'Mi', 'desc': 'Nada Mi dalam tangga nada mayor.'},
    {'note': 'F4', 'solfege': 'Fa', 'desc': 'Nada Fa, berjarak dekat dengan E4.'},
    {'note': 'F#4', 'solfege': 'Fa# / Solb', 'desc': 'Nada kromatik antara F4 & G4.'},
    {'note': 'G4', 'solfege': 'Sol', 'desc': 'Nada Sol, salah satu nada pilar.'},
    {'note': 'G#4', 'solfege': 'Sol# / Lab', 'desc': 'Nada kromatik antara G4 & A4.'},
    {'note': 'A4', 'solfege': 'La (440 Hz)', 'desc': 'Standar tuning instrumen musik.'},
    {'note': 'A#4', 'solfege': 'La# / Sib', 'desc': 'Nada kromatik antara A4 & B4.'},
    {'note': 'B4', 'solfege': 'Si', 'desc': 'Nada terakhir sebelum oktaf baru.'},
    {'note': 'C5', 'solfege': 'Do (Oktaf 5)', 'desc': 'Do tinggi, frekuensi 2x lipat C4.'},
  ];

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
          'Slide 1 dari 3. Apa itu nada. Nada adalah getaran suara teratur yang memiliki tinggi rendah tertentu. Ditulis dalam notasi C4, D4, dan E4.',
          force: true,
        );
        break;
      case 1:
        tts.speak(
          'Slide 2 dari 3. Mengenal oktaf. Oktaf adalah jarak antar nada sejenis yang frekuensinya tepat 2 kali lipat. C5 beroktaf lebih tinggi dari C4.',
          force: true,
        );
        break;
      case 2:
        tts.speak(
          'Slide 3 dari 3. Sentuh dan dengarkan nada. Tekan tombol nada di layar untuk membiasakan telinga sebelum latihan.',
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

  void _playNote(String note) {
    setState(() => _playingNote = note);
    ref.read(audioServiceProvider).playNote(note);

    final mode = ref.read(operatingModeProvider);
    final isSenseMode = mode == AppOperatingMode.sense || ref.read(senseModeProvider);
    if (isSenseMode) {
      final notation = ref.read(noteNotationProvider);
      final spokenNote = ref.read(ttsServiceProvider).formatNoteForSpeech(note, notation);
      ref.read(ttsServiceProvider).speak(spokenNote, force: true);
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted && _playingNote == note) {
        setState(() => _playingNote = null);
      }
    });
  }

  Future<void> _completeIntroduce() async {
    await ref
        .read(educationProgressProvider.notifier)
        .markIntroduceCompleted('note_recognition');
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
                    title: 'NOTE RECOGNITION',
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
                  _speakCurrentSlide();
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

  // Slide 1: Apa itu Nada
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
                    Icons.music_note_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const WhiskerBannerHeader(
                  title: 'APA ITU NADA (NOTE)?',
                  fontSize: 16,
                  rotateAngle: -0.03,
                ),
                const SizedBox(height: 14),
                Text(
                  'Nada adalah getaran suara teratur yang memiliki tinggi-rendah (pitch) tertentu. Di dalam musik barat, nada diberi lambang abjad A sampai G.',
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
                  icon: Icons.lightbulb_rounded,
                  color: Colors.amber.shade800,
                  title: 'NOTASI ILMIAH',
                  description:
                      'Di Melody Sense, nada ditulis sebagai C4, D4, E4, dst. Huruf mewakili nama nada, dan angka mewakili ketinggian oktaf.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Slide 2: Mengenal Oktaf
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
                    Icons.waves_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const WhiskerBannerHeader(
                  title: 'MENGENAL OKTAF (OCTAVE)',
                  fontSize: 16,
                  rotateAngle: -0.03,
                ),
                const SizedBox(height: 14),
                Text(
                  'Oktaf adalah jarak antar dua nada sejenis yang frekuensinya tepat 2 kali lipatnya. C5 memiliki frekuensi 2x lipat lebih tinggi dari C4.',
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
                  icon: Icons.graphic_eq_rounded,
                  color: Colors.purple.shade700,
                  title: 'PERBEDAAN RASA BUNYI',
                  description:
                      'Walau sama-sama bernama "Do", C4 berada di oktaf tengah yang tenang, sementara C5 berada di oktaf atas yang lebih tinggi.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Slide 3: Modul Interaktif Nada
  Widget _buildSlide3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          const WhiskerBannerHeader(
            title: 'SENTUH & DENGARKAN NADA',
            fontSize: 15,
            rotateAngle: -0.03,
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol nada di bawah untuk membiasakan telingamu sebelum berlatih.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
            itemCount: _notesInfo.length,
            itemBuilder: (context, index) {
              final info = _notesInfo[index];
              final note = info['note']!;
              final solfege = info['solfege']!;
              final isPlaying = _playingNote == note;

              return GestureDetector(
                onTap: () => _playNote(note),
                child: StickerBadge(
                  rotateAngle: isPlaying ? -0.04 : 0.02,
                  backgroundColor: isPlaying ? AppColors.accent : AppColors.surfaceWhite,
                  borderColor: AppColors.primaryDark,
                  borderWidth: 2.2,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        note,
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isPlaying ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        solfege,
                        style: GoogleFonts.fredoka(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: isPlaying
                              ? Colors.white.withValues(alpha: 0.9)
                              : AppColors.primaryDark.withValues(alpha: 0.65),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        isPlaying
                            ? Icons.volume_up_rounded
                            : Icons.play_circle_outline_rounded,
                        size: 16,
                        color: isPlaying ? Colors.white : AppColors.primaryDark,
                      ),
                    ],
                  ),
                ),
              );
            },
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
