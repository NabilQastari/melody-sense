import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import '../state/interval_training_state.dart';

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
    'Minor 2nd': ['C4', 'C#4'], // Atau C4 ke D4 semitone dekat
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
    if (_currentPage < 3) {
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
                    'Slide ${_currentPage + 1} dari 4',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark.withValues(alpha: 0.6),
                    ),
                  ),
                  if (_currentPage < 3)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          3,
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

            // ── Slide Content ──
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildSlide1(),
                  _buildSlide2Quality(),
                  _buildSlide2(),
                  _buildSlide3(),
                ],
              ),
            ),

            // ── Bottom Navigation Bar ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
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
                  Row(
                    children: List.generate(4, (index) {
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
                          _currentPage == 3
                              ? 'Selesai & Mulai Latihan'
                              : 'Lanjut',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == 3
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

  // Slide 1: Apa itu Interval & Semitone?
  Widget _buildSlide1() {
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
              Icons.graphic_eq_rounded,
              size: 48,
              color: Colors.purpleAccent,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          const Text(
            'Apa itu Interval & Semitone?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 14),
          Text(
            'Interval adalah jarak lompatan tinggi-rendah antara dua nada musik yang dimainkan berurutan atau bersamaan.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          _buildInfoCard(
            icon: Icons.straighten_rounded,
            color: Colors.blueAccent,
            title: 'Semitone (Satuan Jarak)',
            description:
                'Semitone adalah satuan jarak terkecil antar tuts piano bertetangga. Misalnya, C4 ke D4 adalah jarak 2 semitones (Major 2nd).',
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  // Slide 2 (NEW): Kualitas Interval — Major, Minor, Perfect
  Widget _buildSlide2Quality() {
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
              Icons.category_rounded,
              size: 48,
              color: Colors.orangeAccent,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          const Text(
            'Kualitas Interval:\nMajor, Minor & Perfect',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            'Nama interval terdiri dari dua bagian: kualitas dan angka. Contoh: "Major 3rd" = kualitas Major, jarak 3 anak tangga.',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.primaryDark.withValues(alpha: 0.65),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 450.ms),
          const SizedBox(height: 20),
          _buildQualityCard(
            color: Colors.amber,
            icon: Icons.wb_sunny_rounded,
            quality: 'Major',
            description:
                'Terdengar cerah, optimis, dan kuat. Biasanya dipakai dalam lagu-lagu gembira atau bersemangat. Contoh: Major 3rd (C→E), Major 6th (C→A).',
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 12),
          _buildQualityCard(
            color: Colors.blueAccent,
            icon: Icons.nights_stay_rounded,
            quality: 'Minor',
            description:
                'Terdengar gelap, melankolis, atau emosional. Sering digunakan dalam lagu sedih atau misterius. Contoh: Minor 3rd (D→F), Minor 2nd (C→C#).',
          ).animate().fadeIn(duration: 550.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 12),
          _buildQualityCard(
            color: Colors.green,
            icon: Icons.balance_rounded,
            quality: 'Perfect',
            description:
                'Terdengar sangat stabil, murni, dan seimbang. Kuat secara harmoni dan tidak memiliki rasa tegang. Contoh: Perfect 5th (C→G), Perfect 4th (C→F), Octave (C→C).',
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildQualityCard({
    required Color color,
    required IconData icon,
    required String quality,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quality,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.primaryDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Slide 3: Daftar Interval Musik
  Widget _buildSlide2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Daftar Interval Musik',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
          ).animate().fadeIn(duration: 350.ms),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Tiap interval memiliki kualitas dan jarak semitone yang berbeda.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primaryDark.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kIntervalDefinitions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final interval = kIntervalDefinitions[index];
              // Tentukan warna kualitas dari nama
              Color qualityColor = Colors.grey;
              if (interval.name.startsWith('Major')) qualityColor = Colors.amber.shade700;
              else if (interval.name.startsWith('Minor')) qualityColor = Colors.blueAccent;
              else if (interval.name.startsWith('Perfect') || interval.name == 'Octave') qualityColor = Colors.green;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: qualityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: qualityColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        interval.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: qualityColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${interval.semitones} semitone${interval.semitones == 1 ? "" : "s"}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: qualityColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ).animate().fadeIn(duration: 450.ms),
        ],
      ),
    );
  }

  // Slide 3: Modul Interaktif Dengarkan Jarak Interval
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
                'Sentuh & Dengarkan Jarak',
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
            'Pilih interval di bawah untuk mendengarkan beda loncatan bunyi nada.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryDark.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 16),

          // Chips Interval
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: kIntervalDefinitions.map((interval) {
              final isSelected = _selectedIntervalName == interval.name;
              return ChoiceChip(
                label: Text(interval.name),
                selected: isSelected,
                onSelected: (_) => _playSample(interval.name),
                selectedColor: AppColors.primaryDark,
                backgroundColor: AppColors.surfaceWhite,
                labelStyle: TextStyle(
                  color:
                      isSelected ? AppColors.surfaceWhite : AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.surfaceTint,
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(duration: 450.ms),

          const SizedBox(height: 24),

          // Active Interval Audio Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _selectedIntervalName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sampel nada: ${(_intervalSamples[_selectedIntervalName] ?? ['C4', 'E4']).join(" -> ")}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryDark.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isPlayingSample
                      ? null
                      : () => _playSample(_selectedIntervalName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.surfaceWhite,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(
                    _isPlayingSample
                        ? Icons.volume_up_rounded
                        : Icons.play_arrow_rounded,
                    size: 20,
                  ),
                  label: Text(
                    _isPlayingSample ? 'Memutar Audio...' : 'Putar Contoh Jarak',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),
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
