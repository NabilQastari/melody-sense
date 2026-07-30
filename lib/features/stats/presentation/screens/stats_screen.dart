import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/domain/entities/progression_entities.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/pattern_painters.dart';
import 'package:melody_sense/core/widgets/settings_screen.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';

import '../providers/stats_providers.dart';

/// "Your Progress" — Stats tab (Sesi 7)
/// Diperbarui dengan Whisker-Inspired Design System v3.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    title: 'STATISTICS',
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
            // ── Content ──
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  const WhiskerBannerHeader(
                    title: 'YOUR PROGRESS',
                    fontSize: 18,
                    rotateAngle: -0.04,
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Track your musical journey.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.primaryDark.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Section 1: Level & Streak ──
                  _LevelCard(ref: ref),
                  const SizedBox(height: 22),

                  // ── Section 2: Note Accuracy ──
                  const WhiskerBannerHeader(
                    title: 'NOTE ACCURACY',
                    fontSize: 15,
                    rotateAngle: -0.03,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  const SizedBox(height: 12),
                  _NoteAccuracyChart(ref: ref),
                  const SizedBox(height: 22),

                  // ── Section 3: Badges ──
                  const WhiskerBannerHeader(
                    title: 'BADGES & ACHIEVEMENTS',
                    fontSize: 15,
                    rotateAngle: -0.03,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  const SizedBox(height: 12),
                  _BadgesGrid(ref: ref),
                  const SizedBox(height: 22),

                  // ── Section 4: Practice History ──
                  const WhiskerBannerHeader(
                    title: 'RECENT SESSIONS',
                    fontSize: 15,
                    rotateAngle: -0.03,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  const SizedBox(height: 12),
                  _PracticeHistory(ref: ref),
                ],
              ),
            ),
          ],
        ),
      ),
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

    return TornPaperCard(
      backgroundColor: AppColors.primaryDark,
      shadowColor: AppColors.surfaceTint,
      borderWidth: 2.8,
      tornPosition: TornEdgePosition.both,
      padding: const EdgeInsets.all(18),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            width: 90,
            height: 90,
            child: CustomPaint(
              painter: HalftonePatternPainter(
                color: AppColors.surfaceTint,
                opacity: 0.25,
              ),
            ),
          ),
          levelAsync.when(
            loading: () => const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
            error: (_, __) => const Text('Error loading stats', style: TextStyle(color: Colors.white)),
            data: (level) {
              final streak = streakAsync.valueOrNull ?? 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StickerBadge(
                        rotateAngle: -0.05,
                        backgroundColor: AppColors.accent,
                        borderColor: Colors.white,
                        borderWidth: 2.0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        child: Text(
                          'LEVEL ${level.level}',
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, size: 16, color: AppColors.surfaceTint),
                          const SizedBox(width: 4),
                          Text(
                            '${level.totalXp} XP',
                            style: GoogleFonts.fredoka(
                              color: AppColors.surfaceTint,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      StickerBadge(
                        rotateAngle: 0.04,
                        backgroundColor: AppColors.surfaceWhite,
                        borderColor: AppColors.primaryDark,
                        borderWidth: 2.0,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded,
                                color: Colors.deepOrange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$streak-DAY STREAK',
                              style: GoogleFonts.fredoka(
                                color: AppColors.primaryDark,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTint.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: (level.xpIntoLevel / level.xpForNextLevel).clamp(0.0, 1.0),
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(AppColors.accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${level.xpIntoLevel} / ${level.xpForNextLevel} XP to Level ${level.level + 1}',
                    style: GoogleFonts.fredoka(
                      color: AppColors.surfaceTint,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Section 2 — Note Accuracy Bar Chart
// ═══════════════════════════════════════════════════════════════════

class _NoteAccuracyChart extends StatelessWidget {
  const _NoteAccuracyChart({required this.ref});
  final WidgetRef ref;

  static const _orderedNotes = ['B3', 'C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4', 'C5'];

  @override
  Widget build(BuildContext context) {
    final noteStatsAsync = ref.watch(noteAccuracyProvider);

    return TornPaperCard(
      backgroundColor: AppColors.surfaceWhite,
      shadowColor: AppColors.surfaceTint,
      borderWidth: 2.6,
      tornPosition: TornEdgePosition.bottom,
      padding: const EdgeInsets.all(16),
      child: noteStatsAsync.when(
        loading: () => SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
        ),
        error: (err, _) => SizedBox(
          height: 80,
          child: Center(child: Text('Error loading stats: $err')),
        ),
        data: (statsList) {
          final Map<String, NoteAccuracyStat> statsMap = {
            for (final stat in statsList) stat.note: stat
          };

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 140,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _orderedNotes.map((note) {
                    final stats = statsMap[note];
                    final accuracy = stats?.accuracy ?? 0.0;
                    final total = stats?.totalAttempts ?? 0;
                    return _BarColumn(
                      noteName: note,
                      accuracy: accuracy,
                      totalAttempts: total,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendDot(color: Colors.green.shade600, label: '≥ 80%'),
                  const SizedBox(width: 14),
                  _LegendDot(color: Colors.orange.shade700, label: '50-79%'),
                  const SizedBox(width: 14),
                  _LegendDot(color: Colors.red.shade600, label: '< 50%'),
                  const SizedBox(width: 14),
                  _LegendDot(color: Colors.grey.shade300, label: 'Untested'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.noteName,
    required this.accuracy,
    required this.totalAttempts,
  });

  final String noteName;
  final double accuracy;
  final int totalAttempts;

  @override
  Widget build(BuildContext context) {
    Color barColor;
    if (totalAttempts == 0) {
      barColor = Colors.grey.shade300;
    } else if (accuracy >= 0.8) {
      barColor = Colors.green.shade600;
    } else if (accuracy >= 0.5) {
      barColor = Colors.orange.shade700;
    } else {
      barColor = Colors.red.shade600;
    }

    final barHeightFactor = totalAttempts == 0 ? 0.08 : accuracy.clamp(0.08, 1.0);
    final percentText = totalAttempts == 0 ? '-' : '${(accuracy * 100).round()}%';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          percentText,
          style: GoogleFonts.fredoka(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 18,
          height: 85 * barHeightFactor,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primaryDark, width: 1.5),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          noteName,
          style: GoogleFonts.fredoka(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryDark, width: 1.2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.fredoka(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Section 3 — Badges & Achievements Grid
// ═══════════════════════════════════════════════════════════════════

class _BadgesGrid extends StatelessWidget {
  const _BadgesGrid({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(achievementsProvider);

    return achievementsAsync.when(
      loading: () => SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      ),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (achievements) {
        if (achievements.isEmpty) {
          return const Center(child: Text('No badges available.'));
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.88,
          children: achievements.map((badge) {
            return _BadgeTile(badge: badge);
          }).toList(),
        );
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});
  final AchievementEntry badge;

  @override
  Widget build(BuildContext context) {
    return TornPaperCard(
      backgroundColor: AppColors.surfaceWhite,
      shadowColor: AppColors.surfaceTint,
      borderWidth: 2.2,
      tornPosition: TornEdgePosition.bottom,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StickerBadge(
            rotateAngle: badge.unlocked ? -0.05 : 0,
            backgroundColor: badge.unlocked ? AppColors.accent : AppColors.surfaceTint,
            borderColor: AppColors.primaryDark,
            borderWidth: 1.8,
            padding: const EdgeInsets.all(8),
            child: Icon(
              badge.unlocked ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
              color: badge.unlocked ? Colors.white : AppColors.primaryDark.withValues(alpha: 0.4),
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.fredoka(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: badge.unlocked ? AppColors.primaryDark : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${badge.progressCurrent}/${badge.progressTarget}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Section 4 — Practice History
// ═══════════════════════════════════════════════════════════════════

class _PracticeHistory extends StatelessWidget {
  const _PracticeHistory({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final recentSessionsAsync = ref.watch(recentSessionsProvider);

    return recentSessionsAsync.when(
      loading: () => SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      ),
      error: (err, _) => Text('Error loading history: $err'),
      data: (sessions) {
        if (sessions.isEmpty) {
          return TornPaperCard(
            backgroundColor: AppColors.surfaceWhite,
            shadowColor: AppColors.surfaceTint,
            borderWidth: 2.2,
            tornPosition: TornEdgePosition.bottom,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Belum ada histori sesi latihan.',
                style: TextStyle(fontSize: 12, color: AppColors.primaryDark),
              ),
            ),
          );
        }

        final displaySessions = sessions.take(5).toList();

        return Column(
          children: displaySessions.map((session) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: TornPaperCard(
                backgroundColor: AppColors.surfaceWhite,
                shadowColor: AppColors.surfaceTint,
                borderWidth: 2.4,
                tornPosition: TornEdgePosition.bottom,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    StickerBadge(
                      rotateAngle: -0.04,
                      backgroundColor: AppColors.surfaceTint,
                      borderColor: AppColors.primaryDark,
                      borderWidth: 1.8,
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _getModeIcon(session.mode),
                        color: AppColors.primaryDark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getModeName(session.mode),
                            style: GoogleFonts.fredoka(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Score: ${session.score} • ${_formatTimestamp(session.startedAt)}',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.primaryDark.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StickerBadge(
                      rotateAngle: 0.04,
                      backgroundColor: Colors.green.shade100,
                      borderColor: AppColors.primaryDark,
                      borderWidth: 1.8,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        '+${session.xpEarned} XP',
                        style: GoogleFonts.fredoka(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  IconData _getModeIcon(TrainingMode mode) {
    switch (mode) {
      case TrainingMode.noteRecognition:
        return Icons.music_note_rounded;
      case TrainingMode.intervalTraining:
        return Icons.graphic_eq_rounded;
      case TrainingMode.melodyEcho:
        return Icons.record_voice_over_rounded;
      case TrainingMode.rhythmMatch:
        return Icons.timer_rounded;
    }
  }

  String _getModeName(TrainingMode mode) {
    switch (mode) {
      case TrainingMode.noteRecognition:
        return 'Note Recognition';
      case TrainingMode.intervalTraining:
        return 'Interval Training';
      case TrainingMode.melodyEcho:
        return 'Melody Echo';
      case TrainingMode.rhythmMatch:
        return 'Rhythm Match';
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}
