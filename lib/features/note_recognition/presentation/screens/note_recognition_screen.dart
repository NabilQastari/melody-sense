import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/widgets/explorer_gameplay_screen.dart';
import 'package:melody_sense/core/widgets/session_result_screen.dart';

import '../controllers/note_recognition_controller.dart';

/// Note Recognition — Explorer Mode.
///
/// Sesi 4: wrapper wrapper ini disambungkan penuh ke [NoteRecognitionController]
/// — target nada, xp, hearts, dan progress semuanya berasal dari domain
/// logic + database lewat PracticeRepository.
///
/// Sesi 5: [SessionResultScreen] sekarang diisi streakDays & leveledUp
/// dari [NoteRecognitionController.completeSession] (lewat
/// `state.completion`), bukan placeholder 0/false lagi. Karena
/// completeSession() berjalan async setelah sesi ditandai selesai,
/// layar menunggu `state.completion` terisi dulu sebelum berpindah,
/// supaya data yang ditampilkan sudah final.
class NoteRecognitionScreen extends ConsumerWidget {
  const NoteRecognitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioReady = ref.watch(audioReadyProvider);
    final state = ref.watch(noteRecognitionControllerProvider);
    final controller = ref.read(noteRecognitionControllerProvider.notifier);

    if (state == null || audioReady.isLoading) {
      // Dua hal yang mesti kelar dulu sebelum piano boleh disentuh:
      // Sesi sudah dibuat di database (state != null) DAN semua
      // Sample nada sudah ter-load (audioReady). Belum ada desain
      // Loading khusus, jadi sementara pakai spinner polos.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.isSessionOver && state.completion == null) {
      // Sesi sudah berakhir tapi orkestrasi progression (personal
      // Best/level/streak/achievement) masih berjalan di background —
      // Tahan dulu di spinner supaya SessionResultScreen tidak sempat
      // Menampilkan streakDays/leveledUp yang belum final.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.isSessionOver) {
      final completion = state.completion!;
      // PushReplacement dijadwalkan lewat post-frame callback supaya
      // Tidak memanggil Navigator di tengah proses build.
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
              retryScreenBuilder: (_) => const NoteRecognitionScreen(),
            ),
          ),
        );
      });
    }

    String? correctNote;
    String? wrongNote;
    if (state.feedback == RoundFeedback.correct) {
      correctNote = state.lastPressedNote;
    } else if (state.feedback == RoundFeedback.wrong) {
      correctNote = state.targetNote;
      wrongNote = state.lastPressedNote;
    }

    return ExplorerGameplayScreen(
      targetLabel: 'Play the note',
      targetValue: state.targetNote,
      xp: state.xp,
      livesTotal: state.livesTotal,
      livesRemaining: state.livesRemaining,
      progress: state.progress,
      correctNote: correctNote,
      wrongNote: wrongNote,
      isMysteryRound: state.roundIndex == state.mysteryRoundIndex,
      feedback: state.feedback,
      roundIndex: state.roundIndex,
      totalRounds: state.totalRounds,
      isPlaying: state.isPlaying,
      onClose: () => Navigator.of(context).maybePop(),
      onAutoPlay: controller.playTarget,
      onNotePressed: controller.submitAnswer,
    );
  }
}

