import 'package:flutter/material.dart';
import 'package:melody_sense/core/widgets/maestro_gameplay_screen.dart';

/// Melody Echo — Maestro Mode.
///
/// Wrapper tipis di atas [MaestroGameplayScreen]. Sesi 9 (WebSocket
/// client) akan menyambungkan activeHardwareNote ke data real-time
/// dari Smart Piano.
class MelodyEchoScreen extends StatelessWidget {
  const MelodyEchoScreen({
    super.key,
    this.isConnected = true,
    this.xp = 1240,
    this.progress = 0.4,
    this.activeHardwareNote = 'F4',
  });

  final bool isConnected;
  final int xp;
  final double progress;
  final String? activeHardwareNote;

  @override
  Widget build(BuildContext context) {
    return MaestroGameplayScreen(
      isConnected: isConnected,
      title: 'Repeat the Melody',
      subtitle: 'Listen carefully, then play the notes back.',
      xp: xp,
      progress: progress,
      activeHardwareNote: activeHardwareNote,
      onClose: () => Navigator.of(context).maybePop(),
    );
  }
}