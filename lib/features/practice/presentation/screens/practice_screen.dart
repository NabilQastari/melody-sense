import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/domain/entities/operating_mode.dart';
import 'package:melody_sense/core/network/websocket_service.dart';
import 'package:melody_sense/core/providers/operating_mode_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/providers/websocket_providers.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/settings_screen.dart';
import '../../../stats/presentation/providers/stats_providers.dart';
import '../../../free_play/presentation/screens/free_play_screen.dart';
import '../../../interval_training/presentation/screens/interval_training_submode_picker_screen.dart';
import '../../../melody_echo/presentation/screens/melody_echo_submode_picker_screen.dart';
import '../../../note_recognition/presentation/screens/note_recognition_submode_picker_screen.dart';
import '../../../rhythm_match/presentation/screens/rhythm_match_submode_screen.dart';
import '../models/challenge_info.dart';
import '../widgets/challenge_card.dart';

/// "Practice" tab shell.
///
/// Manages the navigation between the initial "Choose Your Path" screen
/// and the sub-challenge list "Pick a Challenge" internally using state.
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
        subtitle: 'Identify single notes.',
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
        title: 'Melody Echo',
        subtitle: 'Repeat the melody played.',
        icon: Icons.person_rounded,
        difficulty: ChallengeDifficulty.intermediate,
        enabled: true,
        builder: (_) => const MelodyEchoSubmodePickerScreen(),
      ),
      ChallengeInfo(
        title: 'Rhythm Match',
        subtitle: 'Tap along to the song rhythm.',
        icon: Icons.timer_rounded,
        difficulty: ChallengeDifficulty.advanced,
        enabled: true,
        builder: (_) => const RhythmMatchSubmodeScreen(),
      ),
    ];
  }

  void _openChallenge(BuildContext context, ChallengeInfo challenge) {
    if (challenge.builder == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: challenge.builder!));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Shared App Bar Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceTint,
                child: Icon(Icons.person, size: 18, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 10),
              const Text(
                'Melody Sense',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                child: Icon(Icons.settings_outlined, color: AppColors.primaryDark.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
        // ── Body content ──
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _showChallenges ? _buildChallengeList() : _buildChoosePath(),
          ),
        ),
      ],
    );
  }

  // ── SCREEN 1: Choose Your Path ──
  Widget _buildChoosePath() {
    return ListView(
      key: const ValueKey('ChoosePath'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      children: [
        const Text(
          'Choose Your Path',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Select how you'd like to master your skills today.",
          style: TextStyle(fontSize: 13, color: AppColors.primaryDark.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 24),

        // 1. Explorer Mode Card
        _PathCard(
          title: 'Explorer Mode',
          description: 'Play using the virtual piano on your screen. Touch input on phone only.',
          icon: Icons.keyboard_rounded,
          faintIcon: Icons.keyboard_alt_outlined,
          iconColor: Colors.white,
          iconBgColor: AppColors.accent,
          actionLabel: 'Start Exploring',
          onTap: () {
            ref.read(operatingModeProvider.notifier).state = AppOperatingMode.explorer;
            ref.read(ttsServiceProvider).setEnabled(false);
            setState(() {
              _showChallenges = true;
            });
          },
        ),
        const SizedBox(height: 16),

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
            title: 'Maestro Mode',
            titleSuffix: const Icon(Icons.wifi, size: 16, color: AppColors.primaryDark),
            description: 'Connect your Smart Piano via Wi-Fi. Drive challenges using your physical instrument.',
            icon: Icons.piano_rounded,
            faintIcon: Icons.piano_outlined,
            iconColor: Colors.white,
            iconBgColor: AppColors.primaryDark,
            actionLabel: 'Start Maestro',
            actionIcon: Icons.play_arrow_rounded,
            customActionColor: AppColors.primaryDark,
            statusWidget: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceTint.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'Status: Connected' : 'Status: Offline',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isConnected ? wsService.currentIp ?? '192.168.4.1' : 'Connect via Dashboard',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryDark.withValues(alpha: 0.6),
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
        const SizedBox(height: 16),

        // 3. Sense Mode Card
        _PathCard(
          title: 'Sense Mode',
          description: 'Accessibility mode for blind/low-vision users with TTS voice cues & physical ESP32 buttons.',
          icon: Icons.waves_rounded,
          faintIcon: Icons.waves_rounded,
          iconColor: Colors.white,
          iconBgColor: AppColors.accent,
          actionLabel: 'Start Sense',
          onTap: () {
            ref.read(operatingModeProvider.notifier).state = AppOperatingMode.sense;
            ref.read(senseModeProvider.notifier).toggle(true);
            setState(() {
              _showChallenges = true;
            });
          },
        ),
      ],
    );
  }

  // ── SCREEN 2: Challenge List ──
  Widget _buildChallengeList() {
    final challenges = _buildChallenges();
    final mode = ref.watch(operatingModeProvider);

    String modeTitle = 'Explorer Mode (Virtual)';
    Color modeColor = AppColors.accent;
    IconData modeIcon = Icons.keyboard_rounded;

    if (mode == AppOperatingMode.maestro) {
      modeTitle = 'Maestro Mode (ESP32 Hardware)';
      modeColor = AppColors.primaryDark;
      modeIcon = Icons.piano_rounded;
    } else if (mode == AppOperatingMode.sense) {
      modeTitle = 'Sense Mode (Aksesibilitas + ESP32)';
      modeColor = Colors.orange.shade800;
      modeIcon = Icons.waves_rounded;
    }

    return ListView(
      key: const ValueKey('ChallengeList'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _showChallenges = false),
              child: Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTint.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const Text(
              'Pick a Challenge',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: modeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: modeColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(modeIcon, size: 16, color: modeColor),
              const SizedBox(width: 6),
              Text(
                'Mode Aktif: $modeTitle',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: modeColor,
                ),
              ),
            ],
          ),
        ),
        // ── Free Play card ──
        _FreePlayCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FreePlayScreen()),
          ),
        ),
        const SizedBox(height: 20),
        // ── Challenges ──
        for (final challenge in challenges) ...[
          ChallengeCard(
            challenge: challenge,
            onTap: () => _openChallenge(context, challenge),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
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
    this.titleSuffix,
    required this.description,
    required this.icon,
    required this.faintIcon,
    required this.iconColor,
    required this.iconBgColor,
    required this.actionLabel,
    this.actionIcon = Icons.arrow_forward_rounded,
    this.customActionColor,
    this.statusWidget,
    required this.onTap,
  });

  final String title;
  final Widget? titleSuffix;
  final String description;
  final IconData icon;
  final IconData faintIcon;
  final Color iconColor;
  final Color iconBgColor;
  final String actionLabel;
  final IconData actionIcon;
  final Color? customActionColor;
  final Widget? statusWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Faint background icon at top-right
            Positioned(
              right: -10,
              top: -10,
              child: Icon(
                faintIcon,
                size: 110,
                color: Colors.grey.shade100.withValues(alpha: 0.7),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon box
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(height: 16),
                  // Title + Suffix
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      if (titleSuffix != null) ...[
                        const SizedBox(width: 8),
                        titleSuffix!,
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.primaryDark.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Status widget (if any)
                  if (statusWidget != null) statusWidget!,
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customActionColor ?? AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            actionLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(actionIcon, size: 16),
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
}

class _FreePlayCard extends StatelessWidget {
  const _FreePlayCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent,
              AppColors.primaryDark.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.piano_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Main Bebas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Mainkan piano sesuka hati tanpa tantangan.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.white.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Streak: $days Days!',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Complete one more challenge to unlock the "Golden Ear" badge.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.7,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}