import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/widgets/explorer_gameplay_screen.dart';
import 'package:melody_sense/core/widgets/session_result_screen.dart';

import '../controllers/interval_training_controller.dart';

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

    return ExplorerGameplayScreen(
      targetLabel: 'Target',
      targetValue: state.intervalName,
      xp: state.xp,
      livesTotal: state.livesTotal,
      livesRemaining: state.livesRemaining,
      progress: state.progress,
      // Cuma root note yang ditampilkan/didengar duluan — nada kedua
      // (targetNote) sengaja tidak dikirim ke UI, itu yang harus
      // ditebak user lewat tuts piano.
      sequenceNotes: [state.rootNote],
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