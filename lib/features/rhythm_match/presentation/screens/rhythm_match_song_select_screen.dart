import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/whisker_submode_card.dart';

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
    final title = submode == PracticeSubmode.guided
        ? 'GUIDED PRACTICE'
        : 'SELECT SONG';
    final desc = submode == PracticeSubmode.guided
        ? 'Pilih lagu yang ingin kamu latih dengan petunjuk tuts menyala.'
        : 'Pilih lagu dan selesaikan dengan akurasi & ritme terbaikmu.';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            WhiskerSubmodeAppBar(
              title: 'RHYTHM MATCH',
              featureName: title,
              description: desc,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TornPaperCard(
        backgroundColor: AppColors.surfaceWhite,
        shadowColor: AppColors.surfaceTint,
        borderWidth: 2.6,
        tornPosition: TornEdgePosition.bottom,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            StickerBadge(
              rotateAngle: -0.05,
              backgroundColor: AppColors.accent,
              borderColor: AppColors.primaryDark,
              borderWidth: 2.2,
              padding: const EdgeInsets.all(10),
              child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          song.title,
                          style: GoogleFonts.fredoka(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      StickerBadge(
                        rotateAngle: 0.04,
                        backgroundColor: AppColors.surfaceTint,
                        borderColor: AppColors.primaryDark,
                        borderWidth: 1.8,
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        child: Text(
                          song.difficulty.name.toUpperCase(),
                          style: GoogleFonts.fredoka(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${song.artist} • ${song.notes.length} Notes • ${song.bpm} BPM',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark.withValues(alpha: 0.7),
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
