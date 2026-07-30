import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/domain/entities/operating_mode.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/operating_mode_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/providers/websocket_providers.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/session_result_screen.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/virtual_piano.dart';

import '../../domain/entities/song_entity.dart';
import '../controllers/rhythm_match_controller.dart';
import 'rhythm_match_song_select_screen.dart';

class RhythmMatchGameplayScreen extends ConsumerStatefulWidget {
  const RhythmMatchGameplayScreen({
    super.key,
    required this.song,
    this.submode = PracticeSubmode.practice,
  });

  final RhythmSong song;
  final PracticeSubmode submode;

  @override
  ConsumerState<RhythmMatchGameplayScreen> createState() =>
      _RhythmMatchGameplayScreenState();
}

class _RhythmMatchGameplayScreenState
    extends ConsumerState<RhythmMatchGameplayScreen> {
  Timer? _liveTimer;
  Timer? _clearHighlightTimer;
  StreamSubscription<String>? _noteSub;
  int _elapsedMs = 0;
  String? _activeHighlightNote;

  RhythmMatchArgs get _args => RhythmMatchArgs(
        song: widget.song,
        submode: widget.submode,
      );

  @override
  void initState() {
    super.initState();
    _liveTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final state = ref.read(rhythmMatchControllerProvider(_args));
      if (state != null && !state.isSessionOver && state.startedAt != null) {
        if (mounted) {
          setState(() {
            _elapsedMs =
                DateTime.now().difference(state.startedAt!).inMilliseconds;
          });
        }
      }
    });

    // Listen tombol fisik ESP32 via WebSocket hanya jika Maestro / Sense mode
    final mode = ref.read(operatingModeProvider);
    if (mode != AppOperatingMode.explorer) {
      final wsService = ref.read(webSocketServiceProvider);
      _noteSub = wsService.noteStream.listen((note) {
        if (mode == AppOperatingMode.sense) {
          ref.read(ttsServiceProvider).speak('Nada $note');
        }
        _handleNotePressed(note);
      });
    }
  }

  @override
  void dispose() {
    _noteSub?.cancel();
    _liveTimer?.cancel();
    _clearHighlightTimer?.cancel();
    super.dispose();
  }

  int _lastNotePressedMs = 0;

  void _handleNotePressed(String note) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs - _lastNotePressedMs < 150) {
      return; // Ignore accidental double tap within 150ms
    }
    _lastNotePressedMs = nowMs;

    _clearHighlightTimer?.cancel();
    setState(() => _activeHighlightNote = note);

    ref.read(rhythmMatchControllerProvider(_args).notifier).submitNote(note);

    _clearHighlightTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _activeHighlightNote = null);
    });
  }

  String _formatTime(int ms) {
    final seconds = (ms / 1000).toStringAsFixed(1);
    return '${seconds}s';
  }

  String _formatDisplayNote(String note) {
    if (note.contains('#')) {
      return note.replaceAll(RegExp(r'[0-9]'), '');
    }
    return note;
  }

  @override
  Widget build(BuildContext context) {
    final audioReady = ref.watch(audioReadyProvider);
    final state = ref.watch(rhythmMatchControllerProvider(_args));

    if (state == null || audioReady.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Jika lagu selesai dan completion ready → Pindah ke SessionResultScreen
    if (state.isSessionOver && state.completion != null) {
      final completion = state.completion!;
      final seconds = ((state.completedMs ?? 0) / 1000).toStringAsFixed(1);
      final subtitleExplanation =
          'Match "${state.selectedSong.title}" berlangsung selama $seconds detik.\n'
          '${state.perfectCount}/${state.selectedSong.totalNotes} ketukan Perfect (${state.avgResponseTimeMs}ms rata-rata respon).';

      return SessionResultScreen(
        isWin: state.stars >= 1,
        accuracy: state.accuracy,
        xpEarned: state.xp,
        timeSpentMs: state.completedMs,
        stars: state.stars,
        perfectCount: state.perfectCount,
        totalNotes: state.selectedSong.totalNotes,
        customSubtitle: subtitleExplanation,
        streakDays: completion.streakDays,
        leveledUp: completion.leveledUp,
        retryScreenBuilder: (context) => RhythmMatchSongSelectScreen(
          submode: state.submode,
        ),
      );
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isGuided = state.submode == PracticeSubmode.guided;
    final String targetNote = state.targetNote;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: EdgeInsets.fromLTRB(20, isLandscape ? 6 : 12, 20, 0),
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
                      child: Icon(Icons.close_rounded,
                          size: 20, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Song Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.selectedSong.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isLandscape ? 13 : 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          'Note ${state.currentNoteIndex + 1} of ${state.selectedSong.totalNotes}',
                          style: TextStyle(
                            fontSize: isLandscape ? 10 : 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Timer Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined,
                            color: AppColors.surfaceWhite, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(_elapsedMs),
                          style: TextStyle(
                            color: AppColors.surfaceWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: state.progress,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceTint,
                  valueColor: AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            ),

            // Content Display
            if (isLandscape)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDisplayNote(targetNote),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    if (isGuided)
                      const Text(
                        'Petunjuk: Tuts hijau di bawah',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tekan Tuts Nada Berikutnya:',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryDark.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TornPaperCard(
                        width: 120,
                        height: 120,
                        backgroundColor: AppColors.surfaceWhite,
                        shadowColor: AppColors.surfaceTint,
                        borderWidth: 2.8,
                        tornPosition: TornEdgePosition.bottom,
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: StickerBadge(
                            rotateAngle: -0.04,
                            backgroundColor: AppColors.accent,
                            borderColor: AppColors.primaryDark,
                            borderWidth: 2.2,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              _formatDisplayNote(targetNote),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isGuided) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            'Guided: Tuts target disorot hijau',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Virtual Piano
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, isLandscape ? 6 : 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final pianoHeight = isLandscape
                        ? constraints.maxHeight.clamp(80.0, 200.0)
                        : constraints.maxHeight.clamp(80.0, 180.0);
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: VirtualPiano(
                        activeNote: _activeHighlightNote,
                        correctNote: isGuided ? targetNote : null,
                        onNotePressed: _handleNotePressed,
                        height: pianoHeight,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
