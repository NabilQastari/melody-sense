import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/theme/app_colors.dart';

import '../../domain/entities/song_entity.dart';
import 'rhythm_match_gameplay_screen.dart';

class RhythmMatchSongSelectScreen extends ConsumerWidget {
  const RhythmMatchSongSelectScreen({
    super.key,
    required this.submode,
  });

  final PracticeSubmode submode;

  void _onSelectSong(BuildContext context, RhythmSong song) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RhythmMatchGameplayScreen(
          song: song,
          submode: submode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
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
                  Text(
                    submode == PracticeSubmode.guided
                        ? 'Guided Practice — Choose Song'
                        : 'Choose Song',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  Text(
                    submode == PracticeSubmode.guided
                        ? 'Pilih lagu yang ingin kamu latih dengan petunjuk visual.'
                        : 'Pilih lagu dan selesaikan dengan akurasi & waktu terbaikmu.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryDark.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final song in kRhythmSongs) ...[
                    _SongCard(
                      song: song,
                      onTap: () => _onSelectSong(context, song),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  const _SongCard({
    required this.song,
    required this.onTap,
  });

  final RhythmSong song;
  final VoidCallback onTap;

  Color get _difficultyColor {
    switch (song.difficulty) {
      case SongDifficulty.easy:
        return Colors.green;
      case SongDifficulty.medium:
        return Colors.amber.shade800;
      case SongDifficulty.hard:
        return Colors.redAccent;
    }
  }

  IconData get _difficultyIcon {
    switch (song.difficulty) {
      case SongDifficulty.easy:
        return Icons.sentiment_satisfied_alt_rounded;
      case SongDifficulty.medium:
        return Icons.music_note_rounded;
      case SongDifficulty.hard:
        return Icons.bolt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
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
          border: Border.all(
            color: _difficultyColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon Badge
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _difficultyColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_difficultyIcon, color: _difficultyColor, size: 26),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _difficultyColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          song.difficulty.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _difficultyColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${song.totalNotes} Notes',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    song.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.play_circle_fill_rounded,
              color: AppColors.primaryDark,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
