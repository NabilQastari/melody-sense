import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/widgets/explorer_gameplay_screen.dart';
import 'package:melody_sense/core/widgets/session_result_screen.dart';

import '../controllers/rhythm_match_controller.dart';

/// Rhythm Match — Explorer Mode.
///
/// Wrapper screen yang menyambungkan [RhythmMatchController] ke
/// [ExplorerGameplayScreen] shell. Pola sama persis dengan
/// NoteRecognitionScreen & IntervalTrainingScreen:
///
/// 1. Gate ganda: state != null DAN audioReady bukan loading.
/// 2. Menunggu `state.completion` terisi sebelum push ke
///    SessionResultScreen (supaya streakDays/leveledUp sudah final).
/// 3. Retry = pushReplacement ke instance baru (autoDispose bikin
///    controller & sesi baru otomatis).
///
/// Perbedaan utama dari mode lain: controller punya Timer internal
/// untuk timeout per ronde — tapi itu urusan controller, screen ini
/// tidak perlu tahu soal itu (clean separation).
class RhythmMatchScreen extends ConsumerWidget {
  const RhythmMatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioReady = ref.watch(audioReadyProvider);
    final state = ref.watch(rhythmMatchControllerProvider);
    final controller = ref.read(rhythmMatchControllerProvider.notifier);

    if (state == null || audioReady.isLoading) {
      // Dua hal yang mesti kelar dulu sebelum piano boleh disentuh:
      // sesi sudah dibuat di database (state != null) DAN semua
      // sample nada sudah ter-load (audioReady).
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.isSessionOver && state.completion == null) {
      // Sesi sudah berakhir tapi orkestrasi progression (personal
      // best/level/streak/achievement) masih berjalan di background —
      // tahan dulu di spinner supaya SessionResultScreen tidak sempat
      // menampilkan data yang belum final.
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
              retryScreenBuilder: (_) => const RhythmMatchScreen(),
            ),
          ),
        );
      });
    }

    return ExplorerGameplayScreen(
      targetLabel: 'Tap on the beat!',
      targetValue: state.targetNote,
      xp: state.xp,
      livesTotal: state.livesTotal,
      livesRemaining: state.livesRemaining,
      progress: state.progress,
      onClose: () => Navigator.of(context).maybePop(),
      onAutoPlay: controller.playTarget,
      onNotePressed: controller.submitTap,
    );
  }
}
