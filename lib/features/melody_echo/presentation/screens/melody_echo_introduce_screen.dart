import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import 'package:melody_sense/core/widgets/virtual_piano.dart';

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
      // Wrong note — reset
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
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
                    'Introduce: Melody Echo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_currentPage + 1}/3',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: [
                  _buildSlide1(),
                  _buildSlide2(),
                  _buildSlide3Interactive(),
                ],
              ),
            ),

            // Bottom Navigation Indicators & Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accent
                              : AppColors.surfaceTint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishIntroduce();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _currentPage == 2 ? 'Selesai & Mulai' : 'Lanjut',
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceTint.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.record_voice_over_rounded,
                size: 50, color: AppColors.accent),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 28),
          const Text(
            'Apa itu Melody Echo?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Melody Echo adalah latihan mengingat dan mengulang melodi. Aplikasi akan memainkan beberapa nada berurutan, lalu kamu harus meniru melodi tersebut dengan menekan nada yang sama.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildSlide2() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headphones_rounded,
                size: 50, color: Colors.amber),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 28),
          const Text(
            'Dengarkan, Ingat, Ulangi!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '1. Fase Listening: Dengarkan nada-nada yang dimainkan.\n2. Fase Playing: Tekan tuts piano satu per satu sesuai urutan melodi.\n3. Semakin jauh rondenya, melodi akan semakin panjang!',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.7,
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildSlide3Interactive() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'Coba Sekarang!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Dengarkan contoh melodi 3 nada, lalu tirukan di piano!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.primaryDark.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),

          // Action button Play Demo
          ElevatedButton.icon(
            onPressed: _isPlayingDemo ? null : _playDemoSequence,
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: Text(_isPlayingDemo ? 'Memutar Melodi...' : 'Putar Melodi (C4 - E4 - G4)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // User Input Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _targetSequence.length; i++) ...[
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i < _userInputs.length
                        ? Colors.green
                        : AppColors.surfaceTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    i < _userInputs.length ? _userInputs[i] : '?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: i < _userInputs.length
                          ? Colors.white
                          : AppColors.primaryDark.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                if (i < _targetSequence.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),

          if (_isSuccess) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Hebat! Kamu berhasil meniru melodi!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ).animate().scale(curve: Curves.elasticOut),
          ],

          const Spacer(),

          // Virtual Piano Preview
          SizedBox(
            height: 140,
            child: VirtualPiano(
              height: 140,
              activeNote: _activeHighlightNote,
              onNotePressed: _handleUserTap,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
