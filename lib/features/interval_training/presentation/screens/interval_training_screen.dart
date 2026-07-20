import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/widgets/explorer_gameplay_screen.dart';
import 'package:melody_sense/core/widgets/session_result_screen.dart';

import '../controllers/interval_training_controller.dart';
import '../state/interval_training_state.dart';

/// Interval Training — Explorer Mode.
///
/// Sesi 6: wrapper statis (target/xp/progress hardcoded) diganti jadi
/// tersambung penuh ke [IntervalTrainingController] — pola sama persis
/// dengan NoteRecognitionScreen (Sesi 4-5): gate ganda (state != null
/// DAN audioReady bukan loading) sebelum piano bisa disentuh, dan
/// menunggu `state.completion` terisi sebelum pindah ke
/// SessionResultScreen supaya streakDays/leveledUp yang ditampilkan
/// bukan data basi.
class IntervalTrainingScreen extends ConsumerWidget {
  const IntervalTrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioReady = ref.watch(audioReadyProvider);
    final state = ref.watch(intervalTrainingControllerProvider);
    final controller = ref.read(intervalTrainingControllerProvider.notifier);

    if (state == null || audioReady.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.isSessionOver && state.completion == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.isSessionOver) {
      final completion = state.completion!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SessionResultScreen(
              isWin: state.isWin,
              accuracy: state.accuracy,
              xpEarned: state.xp,
              streakDays: completion.streakDays,
              leveledUp: completion.leveledUp,
              retryScreenBuilder: (_) => const IntervalTrainingScreen(),
            ),
          ),
        );
      });
    }

    final isWrong = state.feedback == RoundFeedback.wrong;
    final hasFeedback = state.feedback != RoundFeedback.none;

    String? correctNote;
    String? wrongNote;
    String? bridgeStartNote;
    String? bridgeEndNote;
    String? bridgeLabel;

    // Hanya tampilkan highlight & bridge saat fase feedback (sudah dijawab)
    if (hasFeedback && state.lastPressedNote != null) {
      correctNote = state.targetNote;
      if (isWrong) {
        wrongNote = state.lastPressedNote;

        // Bridge: hubungkan rootNote ke jawaban user (salah) sebagai
        // alat edukasi — user bisa lihat jarak yang dia tekan vs yang benar
        bridgeStartNote = state.rootNote;
        bridgeEndNote = state.lastPressedNote;

        final startSemitone = kSemitoneByNote[state.rootNote] ?? 0;
        final endSemitone = kSemitoneByNote[state.lastPressedNote!] ?? 0;
        final semitones = (endSemitone - startSemitone).abs();
        bridgeLabel = '$semitones semitone${semitones == 1 ? "" : "s"}';
      }
    }

    return ExplorerGameplayScreen(
      targetLabel: 'Target',
      targetValue: state.intervalName,
      xp: state.xp,
      livesTotal: state.livesTotal,
      livesRemaining: state.livesRemaining,
      progress: state.progress,
      // Kosongkan sequenceNotes — rootNote TIDAK ditampilkan di UI agar
      // user tidak bisa menghitung jarak secara visual dari posisi tuts.
      // Tantangannya harus murni mengandalkan pendengaran.
      sequenceNotes: const [],
      correctNote: correctNote,
      wrongNote: wrongNote,
      bridgeStartNote: bridgeStartNote,
      bridgeEndNote: bridgeEndNote,
      bridgeLabel: bridgeLabel,
      isMysteryRound: state.roundIndex == state.mysteryRoundIndex,
      feedback: state.feedback,
      roundIndex: state.roundIndex,
      totalRounds: state.totalRounds,
      isPlaying: state.isPlaying,
      onClose: () => Navigator.of(context).maybePop(),
      onAutoPlay: controller.playSequence,
      onHint: () {
        // Belum diputuskan — lihat status "Cheat Note" di context file,
        // belum bergerak sejak Sesi 3.
      },
      onNotePressed: controller.submitAnswer,
    );
  }
}