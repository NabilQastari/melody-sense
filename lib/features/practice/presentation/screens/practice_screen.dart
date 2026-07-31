import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:melody_sense/core/domain/entities/operating_mode.dart';
import 'package:melody_sense/core/network/websocket_service.dart';
import 'package:melody_sense/core/providers/operating_mode_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/providers/websocket_providers.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/pattern_painters.dart';
import 'package:melody_sense/core/widgets/settings_screen.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';
import '../../../free_play/presentation/screens/free_play_screen.dart';
import '../../../interval_training/presentation/screens/interval_training_submode_picker_screen.dart';
import '../../../melody_echo/presentation/screens/melody_echo_submode_picker_screen.dart';
import '../../../note_recognition/presentation/screens/note_recognition_submode_picker_screen.dart';
import '../../../rhythm_match/presentation/screens/rhythm_match_submode_screen.dart';
import '../../../stats/presentation/providers/stats_providers.dart';
import '../models/challenge_info.dart';
import '../widgets/challenge_card.dart';

/// "Practice" tab shell refactored 100% dengan Whisker-Inspired Design System v3.
class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  bool _showChallenges = false;

  List<ChallengeInfo> _buildChallenges() {
    return [
      ChallengeInfo(
        title: 'Note Recognition',
        subtitle: 'Identify single notes visually or by ear.',
        icon: Icons.radio_button_checked_rounded,
        difficulty: ChallengeDifficulty.beginner,
        enabled: true,
        builder: (_) => const NoteRecognitionSubmodePickerScreen(),
      ),
      ChallengeInfo(
        title: 'Interval Training',
        subtitle: 'Hear the distance between notes.',
        icon: Icons.headphones_rounded,
        difficulty: ChallengeDifficulty.intermediate,
        enabled: true,
        builder: (_) => const IntervalTrainingSubmodePickerScreen(),
      ),
      ChallengeInfo(
        title: 'Rhythm Match',
        subtitle: 'Tap along to the song rhythm.',
        icon: Icons.timer_rounded,
        difficulty: ChallengeDifficulty.intermediate,
        enabled: true,
        builder: (_) => const RhythmMatchSubmodeScreen(),
      ),
      ChallengeInfo(
        title: 'Melody Echo',
        subtitle: 'Repeat the melody played.',
        icon: Icons.person_rounded,
        difficulty: ChallengeDifficulty.advanced,
        enabled: true,
        builder: (_) => const MelodyEchoSubmodePickerScreen(),
      ),
    ];
  }

  void _openChallenge(BuildContext context, ChallengeInfo challenge) {
    if (challenge.builder == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: challenge.builder!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Shared App Bar Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTint,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryDark, width: 2.5),
                    ),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.surfaceWhite,
                      child: Icon(Icons.person, size: 18, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const WhiskerBannerHeader(
                    title: 'PRACTICE',
                    fontSize: 15,
                    rotateAngle: -0.03,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryDark, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.2),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: AppColors.primaryDark,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Body Content ──
            Expanded(
              child: _showChallenges ? _buildChallengeList() : _buildChoosePath(),
            ),
          ],
        ),
      ),
    );
  }

  // ── SCREEN 1: Choose Your Path ──
  Widget _buildChoosePath() {
    return ListView(
      key: const ValueKey('ChoosePath'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const WhiskerBannerHeader(
          title: 'PILIH MODE OPERASIONAL',
          fontSize: 18,
          rotateAngle: -0.04,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        ),
        const SizedBox(height: 8),
        Text(
          'Tentukan bagaimana kamu ingin berinteraksi dan mengasah kemampuan musikmu.',
          style: GoogleFonts.fredoka(
            fontSize: 12.5,
            color: AppColors.primaryDark.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 20),

        // 1. Explorer Mode Card
        _PathCard(
          title: 'EXPLORER MODE',
          tag: 'TOUCHSCREEN',
          description:
              'Berlatih menggunakan piano virtual di layar HP. Cocok untuk belajar mandiri tanpa memerlukan alat fisik.',
          icon: Icons.keyboard_rounded,
          iconColor: Colors.white,
          iconBgColor: AppColors.accent,
          actionLabel: 'START EXPLORER',
          customActionColor: AppColors.accent,
          statusWidget: StickerBadge(
            rotateAngle: -0.03,
            backgroundColor: AppColors.surfaceTint,
            borderColor: AppColors.primaryDark,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_rounded, size: 14, color: AppColors.primaryDark),
                SizedBox(width: 6),
                Text(
                  'Input: Piano Virtual (Touchscreen Only)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            ref.read(operatingModeProvider.notifier).state = AppOperatingMode.explorer;
            ref.read(ttsServiceProvider).setEnabled(false);
            setState(() {
              _showChallenges = true;
            });
          },
        ),
        const SizedBox(height: 18),

        // 2. Maestro Mode Card
        () {
          final connectionStateAsync = ref.watch(webSocketConnectionStateProvider);
          final wsService = ref.watch(webSocketServiceProvider);
          final connectionState = connectionStateAsync.maybeWhen(
            data: (s) => s,
            orElse: () => wsService.connectionState,
          );
          final isConnected = connectionState == WebSocketConnectionState.connected;

          return _PathCard(
            title: 'MAESTRO MODE',
            tag: 'HARDWARE ESP32',
            description:
                'Sambungkan Smart Piano via Wi-Fi. Jalankan tantangan menggunakan instrumen fisik milikmu.',
            icon: Icons.piano_rounded,
            iconColor: Colors.white,
            iconBgColor: AppColors.darkContainer,
            actionLabel: 'START MAESTRO',
            customActionColor: AppColors.darkContainer,
            statusWidget: StickerBadge(
              rotateAngle: 0.03,
              backgroundColor: isConnected
                  ? (AppColors.isDark ? const Color(0xFF1B3E2B) : Colors.green.shade100)
                  : (AppColors.isDark ? const Color(0xFF3E1B1B) : Colors.red.shade100),
              borderColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_rounded,
                      size: 14,
                      color: isConnected
                          ? (AppColors.isDark ? const Color(0xFF81C784) : Colors.green.shade900)
                          : (AppColors.isDark ? const Color(0xFFEF9A9A) : Colors.red.shade900)),
                  const SizedBox(width: 6),
                  Text(
                    isConnected ? 'ESP32 Connected' : 'ESP32 Offline (Connect via Dashboard)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isConnected
                          ? (AppColors.isDark ? const Color(0xFF81C784) : Colors.green.shade900)
                          : (AppColors.isDark ? const Color(0xFFEF9A9A) : Colors.red.shade900),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              ref.read(operatingModeProvider.notifier).state = AppOperatingMode.maestro;
              ref.read(ttsServiceProvider).setEnabled(false);
              setState(() {
                _showChallenges = true;
              });
            },
          );
        }(),
        const SizedBox(height: 18),

        // 3. Sense Mode Card
        () {
          final connectionStateAsync = ref.watch(webSocketConnectionStateProvider);
          final wsService = ref.watch(webSocketServiceProvider);
          final connectionState = connectionStateAsync.maybeWhen(
            data: (s) => s,
            orElse: () => wsService.connectionState,
          );
          final isConnected = connectionState == WebSocketConnectionState.connected;

          return _PathCard(
            title: 'SENSE MODE',
            tag: 'ACCESSIBILITY & TTS',
            description:
                'Sensori penuh untuk pembelajar tunanetra. Dilengkapi panduan suara TTS & umpan balik taktil.',
            icon: Icons.record_voice_over_rounded,
            iconColor: Colors.white,
            iconBgColor: Colors.orange.shade800,
            actionLabel: 'START SENSE',
            customActionColor: Colors.orange.shade800,
            statusWidget: StickerBadge(
              rotateAngle: -0.03,
              backgroundColor: Colors.orange.shade100,
              borderColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.record_voice_over_rounded,
                      size: 14, color: AppColors.primaryDark),
                  const SizedBox(width: 6),
                  Text(
                    'TTS Voice & Audio Cues Active (${isConnected ? "ESP32 Ready" : "Hardware Offline"})',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              ref.read(operatingModeProvider.notifier).state = AppOperatingMode.sense;
              ref.read(senseModeProvider.notifier).toggle(true);
              setState(() {
                _showChallenges = true;
              });
            },
          );
        }(),
      ],
    );
  }

  // ── SCREEN 2: Challenge List ──
  Widget _buildChallengeList() {
    final challenges = _buildChallenges();
    final mode = ref.watch(operatingModeProvider);

    String modeTitle = 'EXPLORER MODE';
    Color modeColor = AppColors.accent;

    if (mode == AppOperatingMode.maestro) {
      modeTitle = 'MAESTRO MODE';
      modeColor = AppColors.darkContainer;
    } else if (mode == AppOperatingMode.sense) {
      modeTitle = 'SENSE MODE';
      modeColor = Colors.orange.shade800;
    }

    return ListView(
      key: const ValueKey('ChallengeList'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _showChallenges = false),
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryDark, width: 2.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.15),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            WhiskerBannerHeader(
              title: modeTitle,
              fontSize: 16,
              rotateAngle: -0.04,
              backgroundColor: modeColor,
              textColor: Colors.white,
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Free Play Card (Whisker Card)
        _FreePlayCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FreePlayScreen()),
          ),
        ),
        const SizedBox(height: 18),

        const WhiskerBannerHeader(
          title: 'CHALLENGES',
          fontSize: 15,
          rotateAngle: -0.03,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        const SizedBox(height: 14),

        // Challenges
        for (final challenge in challenges) ...[
          ChallengeCard(
            challenge: challenge,
            onTap: () => _openChallenge(context, challenge),
          ),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 10),
        ref.watch(streakProvider).maybeWhen(
              data: (days) => _StreakBanner(days: days),
              orElse: () => const _StreakBanner(days: 0),
            ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Helper widgets
// ═══════════════════════════════════════════════════════════════════

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.title,
    required this.tag,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.actionLabel,
    required this.customActionColor,
    required this.statusWidget,
    required this.onTap,
  });

  final String title;
  final String tag;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String actionLabel;
  final Color customActionColor;
  final Widget statusWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TornPaperCard(
      backgroundColor: AppColors.surfaceWhite,
      shadowColor: AppColors.surfaceTint,
      borderWidth: 2.8,
      tornPosition: TornEdgePosition.bottom,
      padding: const EdgeInsets.all(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StickerBadge(
                    rotateAngle: -0.05,
                    backgroundColor: iconBgColor,
                    borderColor: AppColors.primaryDark,
                    borderWidth: 2.4,
                    padding: const EdgeInsets.all(10),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        StickerBadge(
                          rotateAngle: 0.04,
                          backgroundColor: AppColors.surfaceTint,
                          borderColor: AppColors.primaryDark,
                          borderWidth: 1.8,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            tag,
                            style: GoogleFonts.fredoka(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryDark.withValues(alpha: 0.75),
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              statusWidget,
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onTap,
                  child: StickerBadge(
                    rotateAngle: 0.04,
                    backgroundColor: customActionColor,
                    borderColor: AppColors.primaryDark,
                    borderWidth: 2.2,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          actionLabel,
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FreePlayCard extends StatelessWidget {
  const _FreePlayCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TornPaperCard(
      backgroundColor: AppColors.surfaceTint.withValues(alpha: 0.5),
      shadowColor: AppColors.surfaceTint,
      borderWidth: 2.8,
      tornPosition: TornEdgePosition.both,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          StickerBadge(
            rotateAngle: -0.05,
            backgroundColor: AppColors.accent,
            borderColor: AppColors.primaryDark,
            borderWidth: 2.2,
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.piano_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FREE PLAY PIANO',
                  style: GoogleFonts.fredoka(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mainkan nada bebas tanpa batas.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.primaryDark.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: StickerBadge(
              rotateAngle: 0.04,
              backgroundColor: AppColors.accent,
              borderColor: Colors.white,
              borderWidth: 2.0,
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    return TornPaperCard(
      backgroundColor: AppColors.surfaceWhite,
      shadowColor: AppColors.surfaceTint,
      borderWidth: 2.6,
      tornPosition: TornEdgePosition.bottom,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          StickerBadge(
            rotateAngle: -0.06,
            backgroundColor: Colors.deepOrange,
            borderColor: AppColors.primaryDark,
            borderWidth: 2.2,
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$days-DAY STREAK',
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'Latihan tiap hari untuk menjaga ritme!',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryDark.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
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