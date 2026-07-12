import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/widgets/explorer_gameplay_screen.dart';

/// Note Recognition — Explorer Mode.
///
/// Wrapper tipis: menyuplai data spesifik latihan ini ke
/// [ExplorerGameplayScreen] dan menyambungkan aksi (Auto Play, tekan
/// tuts) ke [AudioService] lewat Riverpod. Sesi 4 akan menambahkan
/// domain logic (cek jawaban benar/salah, catat attempt, dst.).
class NoteRecognitionScreen extends ConsumerWidget {
  const NoteRecognitionScreen({
    super.key,
    this.targetNote = 'C4',
    this.xp = 450,
    this.livesTotal = 3,
    this.livesRemaining = 3,
    this.progress = 0.35,
  });

  final String targetNote;
  final int xp;
  final int livesTotal;
  final int livesRemaining;
  final double progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);

    return ExplorerGameplayScreen(
      targetLabel: 'Play the note',
      targetValue: targetNote,
      xp: xp,
      livesTotal: livesTotal,
      livesRemaining: livesRemaining,
      progress: progress,
      onClose: () => Navigator.of(context).maybePop(),
      onAutoPlay: () => audioService.playNote(targetNote),
      onNotePressed: (note) {
        audioService.playNote(note);
        // Sesi 4: cek note == targetNote, catat attempt, update hearts/xp
      },
    );
  }
}