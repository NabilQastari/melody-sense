import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../interval_training/presentation/screens/interval_training_screen.dart';
import '../../../melody_echo/presentation/screens/melody_echo_screen.dart';
import '../../../note_recognition/presentation/screens/note_recognition_screen.dart';
import '../../../rhythm_match/presentation/screens/rhythm_match_screen.dart';
import '../models/challenge_info.dart';
import '../widgets/challenge_card.dart';

/// "Pick a Challenge" — konten tab Practice.
///
/// Bukan lagi Scaffold mandiri — ini cuma konten yang ditampilkan
/// di dalam [HomeScreen] lewat IndexedStack. Scaffold dan bottom nav
/// ditangani HomeScreen.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  // TODO: replace with real data once ProgressionRepository exposes a
  // standalone streak watcher.
  static const int _mockStreakDays = 5;

  List<ChallengeInfo> _buildChallenges() {
    return [
      ChallengeInfo(
        title: 'Note Recognition',
        subtitle: 'Identify single notes.',
        icon: Icons.radio_button_checked_rounded,
        difficulty: ChallengeDifficulty.beginner,
        enabled: true,
        builder: (_) => const NoteRecognitionScreen(),
      ),
      ChallengeInfo(
        title: 'Interval Training',
        subtitle: 'Hear the distance between notes.',
        icon: Icons.headphones_rounded,
        difficulty: ChallengeDifficulty.intermediate,
        enabled: true,
        builder: (_) => const IntervalTrainingScreen(),
      ),
      ChallengeInfo(
        title: 'Melody Echo',
        subtitle: 'Repeat the melody played.',
        icon: Icons.person_rounded,
        difficulty: ChallengeDifficulty.intermediate,
        enabled: true,
        builder: (_) => const MelodyEchoScreen(),
      ),
      ChallengeInfo(
        title: 'Rhythm Match',
        subtitle: 'Tap along to the beat.',
        icon: Icons.timer_rounded,
        difficulty: ChallengeDifficulty.advanced,
        enabled: true,
        builder: (_) => const RhythmMatchScreen(),
      ),
    ];
  }

  void _openChallenge(BuildContext context, ChallengeInfo challenge) {
    if (challenge.builder == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: challenge.builder!));
  }

  @override
  Widget build(BuildContext context) {
    final challenges = _buildChallenges();

    return Column(
      children: [
        // App bar header
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
              Icon(Icons.settings_outlined, color: AppColors.primaryDark.withValues(alpha: 0.6)),
            ],
          ),
        ),
        // Content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            children: [
              const Text(
                'Pick a Challenge',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Master your musical ear through daily play.',
                style: TextStyle(fontSize: 13, color: AppColors.primaryDark.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 20),
              for (final challenge in challenges) ...[
                ChallengeCard(
                  challenge: challenge,
                  onTap: () => _openChallenge(context, challenge),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              const _StreakBanner(days: _mockStreakDays),
            ],
          ),
        ),
      ],
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