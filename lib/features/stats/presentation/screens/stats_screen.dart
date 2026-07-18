import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/domain/entities/progression_entities.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/settings_screen.dart';

import '../providers/stats_providers.dart';

/// "Your Progress" — the Stats tab (Sesi 7).
///
/// Scrollable screen with 4 sections:
/// 1. Header + Level progress card
/// 2. Note Accuracy bar chart (custom, no external charting lib)
/// 3. Badges / Achievements grid
/// 4. Practice History (recent sessions)
///
/// All data comes from existing DAO/Repository infrastructure
/// (Sesi 2 & 5) — this screen is purely presentation layer.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // App bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceTint,
                child: Icon(Icons.person, size: 18,
                    color: AppColors.primaryDark),
              ),
              const SizedBox(width: 10),
              const Text(
                'Melody Sense',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                child: Icon(Icons.settings_outlined,
                    color: AppColors.primaryDark.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            children: [
              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track your musical journey.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryDark.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 20),

              // ── Section 1: Level & Streak ──
              _LevelCard(ref: ref),
              const SizedBox(height: 24),

              // ── Section 2: Note Accuracy ──
              _SectionTitle(title: 'Note Accuracy'),
              const SizedBox(height: 12),
              _NoteAccuracyChart(ref: ref),
              const SizedBox(height: 24),

              // ── Section 3: Badges ──
              _SectionTitle(title: 'Badges'),
              const SizedBox(height: 12),
              _BadgesGrid(ref: ref),
              const SizedBox(height: 24),

              // ── Section 4: Practice History ──
              _SectionTitle(title: 'Recent Sessions'),
              const SizedBox(height: 12),
              _PracticeHistory(ref: ref),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Section 1 — Level & Streak Card
// ═══════════════════════════════════════════════════════════════════

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final levelAsync = ref.watch(levelInfoProvider);
    final streakAsync = ref.watch(streakProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: levelAsync.when(
        loading: () => const _CardLoader(),
        error: (_, __) => const _CardError(),
        data: (level) {
          final streak = streakAsync.valueOrNull ?? 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Level ${level.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // XP label
                  Text(
                    '${level.totalXp} XP',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Streak
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: Colors.deepOrange, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$streak-Day Streak',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: level.progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${level.xpIntoLevel} / ${level.xpForNextLevel} XP to Level ${level.level + 1}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Section 2 — Note Accuracy Bar Chart (custom, no external lib)
// ═══════════════════════════════════════════════════════════════════

class _NoteAccuracyChart extends StatelessWidget {
  const _NoteAccuracyChart({required this.ref});
  final WidgetRef ref;

  /// Urutan nada sesuai piano (B3–C5), supaya bar chart selalu
  /// konsisten meskipun database mengembalikan urutan berbeda.
  static const _noteOrder = [
    'B3', 'C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4', 'C5',
  ];

  @override
  Widget build(BuildContext context) {
    final accuracyAsync = ref.watch(noteAccuracyProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: accuracyAsync.when(
        loading: () => const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (_, __) => const SizedBox(
          height: 160,
          child: Center(child: Text('Failed to load data')),
        ),
        data: (stats) {
          // Map stats by note for O(1) lookup
          final statsByNote = {for (final s in stats) s.note: s};

          return SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < _noteOrder.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: _AccuracyBar(
                      note: _noteOrder[i],
                      accuracy: statsByNote[_noteOrder[i]]?.accuracy ?? 0.0,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AccuracyBar extends StatelessWidget {
  const _AccuracyBar({required this.note, required this.accuracy});
  final String note;
  final double accuracy;

  @override
  Widget build(BuildContext context) {
    final percent = (accuracy * 100).round();
    // Bar height: min 4px (empty state), max fills available space
    const maxBarHeight = 130.0;
    final barHeight = (maxBarHeight * accuracy).clamp(4.0, maxBarHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Percentage label
        Text(
          '$percent%',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: accuracy > 0
                ? AppColors.primaryDark
                : AppColors.primaryDark.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 4),
        // Bar
        Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: accuracy > 0 ? AppColors.accent : AppColors.surfaceTint,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        // Note label
        Text(
          note,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Section 3 — Badges / Achievements Grid
// ═══════════════════════════════════════════════════════════════════

class _BadgesGrid extends StatelessWidget {
  const _BadgesGrid({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(achievementsProvider);

    return achievementsAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox(
        height: 100,
        child: Center(child: Text('Failed to load badges')),
      ),
      data: (achievements) {
        if (achievements.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Play some sessions to start earning badges!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryDark.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: achievements.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) =>
              _BadgeCard(achievement: achievements[index]),
        );
      },
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.achievement});
  final AchievementEntry achievement;

  IconData get _icon {
    // Map achievement titles to fitting icons
    final title = achievement.title.toLowerCase();
    if (title.contains('first')) return Icons.star_rounded;
    if (title.contains('dedicated')) return Icons.school_rounded;
    if (title.contains('master')) return Icons.music_note_rounded;
    if (title.contains('perfect')) return Icons.verified_rounded;
    if (title.contains('century') || title.contains('scorer')) {
      return Icons.emoji_events_rounded;
    }
    if (title.contains('fire') || title.contains('streak')) {
      return Icons.local_fire_department_rounded;
    }
    return Icons.workspace_premium_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.unlocked;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.accent.withValues(alpha: 0.12)
            : AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? AppColors.accent.withValues(alpha: 0.3)
              : AppColors.surfaceTint.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                _icon,
                size: 20,
                color: isUnlocked
                    ? AppColors.accent
                    : AppColors.primaryDark.withValues(alpha: 0.3),
              ),
              if (isUnlocked) ...[
                const Spacer(),
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.accent, size: 16),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            achievement.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isUnlocked
                  ? AppColors.primaryDark
                  : AppColors.primaryDark.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: achievement.progressRatio.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: isUnlocked
                  ? AppColors.accent.withValues(alpha: 0.2)
                  : AppColors.surfaceTint,
              valueColor: AlwaysStoppedAnimation(
                isUnlocked ? AppColors.accent : AppColors.primaryDarkFaded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Section 4 — Practice History (Recent Sessions)
// ═══════════════════════════════════════════════════════════════════

class _PracticeHistory extends StatelessWidget {
  const _PracticeHistory({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(recentSessionsProvider);

    return sessionsAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox(
        height: 100,
        child: Center(child: Text('Failed to load sessions')),
      ),
      data: (sessions) {
        if (sessions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'No sessions yet. Start practicing!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryDark.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          );
        }

        // Show max 10 recent sessions
        final recent = sessions.take(10).toList();

        return Column(
          children: [
            for (int i = 0; i < recent.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _SessionTile(session: recent[i]),
            ],
          ],
        );
      },
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final PracticeSession session;

  IconData get _modeIcon => switch (session.mode) {
        TrainingMode.noteRecognition => Icons.radio_button_checked_rounded,
        TrainingMode.intervalTraining => Icons.headphones_rounded,
        TrainingMode.melodyEcho => Icons.person_rounded,
        TrainingMode.rhythmMatch => Icons.timer_rounded,
      };

  String get _modeLabel => switch (session.mode) {
        TrainingMode.noteRecognition => 'Note Recognition',
        TrainingMode.intervalTraining => 'Interval Training',
        TrainingMode.melodyEcho => 'Melody Echo',
        TrainingMode.rhythmMatch => 'Rhythm Match',
      };

  String get _dateLabel {
    final d = session.endedAt ?? session.startedAt;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(d.year, d.month, d.day);
    final diff = today.difference(sessionDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          // Mode icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceTint.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_modeIcon, size: 18, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          // Mode name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _modeLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _dateLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryDark.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          // Score & XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Score: ${session.score}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on,
                      color: Colors.amber, size: 12),
                  const SizedBox(width: 3),
                  Text(
                    '+${session.xpEarned}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Shared helpers
// ═══════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
      ),
    );
  }
}

class _CardLoader extends StatelessWidget {
  const _CardLoader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 80,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white54,
        ),
      ),
    );
  }
}

class _CardError extends StatelessWidget {
  const _CardError();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 80,
      child: Center(
        child: Text(
          'Something went wrong',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ),
    );
  }
}
