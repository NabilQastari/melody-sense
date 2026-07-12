import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/widgets/explorer_gameplay_screen.dart';

/// Interval Training — Explorer Mode.
///
/// Wrapper tipis di atas [ExplorerGameplayScreen], disambungkan ke
/// [AudioService] lewat Riverpod. Auto Play memutar `sequenceNotes`
/// yang sudah diketahui; logic penentuan interval/target penuh
/// (mis. nada kedua dari "Major 3rd") baru masuk di Sesi 6.
class IntervalTrainingScreen extends ConsumerWidget {
  const IntervalTrainingScreen({
    super.key,
    this.targetInterval = 'Major 3rd',
    this.xp = 1240,
    this.progress = 0.4,
    this.sequenceNotes = const ['C4'],
  });

  final String targetInterval;
  final int xp;
  final double progress;
  final List<String> sequenceNotes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioServiceProvider);

    return ExplorerGameplayScreen(
      targetLabel: 'Target',
      targetValue: targetInterval,
      xp: xp,
      progress: progress,
      sequenceNotes: sequenceNotes,
      onClose: () => Navigator.of(context).maybePop(),
      onAutoPlay: () => audioService.playSequence(sequenceNotes),
      onHint: () {
        // Belum diputuskan (lihat status "Cheat Note" di context file)
      },
      onNotePressed: (note) {
        audioService.playNote(note);
        // Sesi 6: cocokkan urutan nada dengan target interval
      },
    );
  }
}