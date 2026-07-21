import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';

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
    {'note': 'D4', 'solfege': 'Re', 'desc': 'Satu langkah di atas C4.'},
    {'note': 'E4', 'solfege': 'Mi', 'desc': 'Nada Mi dalam tangga nada mayor.'},
    {'note': 'F4', 'solfege': 'Fa', 'desc': 'Nada Fa, berjarak dekat dengan E4.'},
    {'note': 'G4', 'solfege': 'Sol', 'desc': 'Nada Sol, salah satu nada pilar.'},
    {'note': 'A4', 'solfege': 'La (440 Hz)', 'desc': 'Standar tuning instrumen musik.'},
    {'note': 'B4', 'solfege': 'Si', 'desc': 'Nada terakhir sebelum oktaf baru.'},
    {'note': 'C5', 'solfege': 'Do (Oktaf 5)', 'desc': 'Do tinggi, frekuensi 2x lipat C4.'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _playNote(String note) {
    setState(() => _playingNote = note);
    ref.read(audioServiceProvider).playNote(note);
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

  // Slide 1: Apa itu Nada
  Widget _buildSlide1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.music_note_rounded,
              size: 48,
              color: Colors.blueAccent,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          const Text(
            'Apa itu Nada (Note)?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 14),
          Text(
            'Nada adalah getaran suara teratur yang memiliki tinggi-rendah (pitch) tertentu. Di dalam musik barat, nada diberi lambang abjad A sampai G.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          _buildInfoCard(
            icon: Icons.lightbulb_rounded,
            color: Colors.amber,
            title: 'Notasi Ilmiah',
            description:
                'Di Melody Sense, nada ditulis sebagai C4, D4, E4, dst. Huruf mewakili nama nada, dan angka mewakili ketinggian oktaf.',
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  // Slide 2: Mengenal Oktaf
  Widget _buildSlide2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.purpleAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.waves_rounded,
              size: 48,
              color: Colors.purpleAccent,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          const Text(
            'Mengenal Oktaf (Octave)',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 14),
          Text(
            'Oktaf adalah jarak antar dua nada sejenis yang frekuensinya tepat 2 kali lipatnya. C5 memiliki frekuensi 2x lipat lebih tinggi dari C4.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          _buildInfoCard(
            icon: Icons.graphic_eq_rounded,
            color: Colors.purpleAccent,
            title: 'Perbedaan Rasa Bunyi',
            description:
                'Walau sama-sama bernama "Do", C4 berada di oktaf tengah yang tenang, sementara C5 berada di oktaf atas yang lebih bernada tinggi.',
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  // Slide 3: Modul Interaktif Nada
  Widget _buildSlide3() {
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
                child: const Icon(Icons.headphones_rounded,
                    color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                'Sentuh & Dengarkan Nada',
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
            'Tekan tombol nada di bawah untuk membiasakan telingamu sebelum berlatih.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryDark.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms),
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isPlaying ? AppColors.accent : AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPlaying ? Colors.transparent : AppColors.surfaceTint,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        note,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isPlaying
                              ? AppColors.surfaceWhite
                              : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        solfege,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isPlaying
                              ? AppColors.surfaceWhite.withValues(alpha: 0.8)
                              : AppColors.primaryDark.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        isPlaying
                            ? Icons.volume_up_rounded
                            : Icons.play_circle_outline_rounded,
                        size: 16,
                        color: isPlaying
                            ? AppColors.surfaceWhite
                            : AppColors.primaryDark.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ).animate().fadeIn(duration: 450.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
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
