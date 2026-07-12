import 'package:flutter/material.dart';
import 'package:melody_sense/core/widgets/maestro_gameplay_screen.dart';

/// Challenge/Combo gameplay — Maestro Mode (mis. "C Major Arpeggio").
///
/// Wrapper tipis di atas [MaestroGameplayScreen], sesuai desain 05d.
/// Bedanya dari Melody Echo: tidak ada mascot/subtitle di portrait,
/// tapi ada comboCount.
class MaestroChallengeScreen extends StatelessWidget {
  const MaestroChallengeScreen({
    super.key,
    this.isConnected = true,
    this.challengeName = 'C Major Arpeggio',
    this.progress = 0.65,
    this.comboCount = 8,
    this.activeHardwareNote = 'G4',
  });

  final bool isConnected;
  final String challengeName;
  final double progress;
  final int comboCount;
  final String? activeHardwareNote;

  @override
  Widget build(BuildContext context) {
    return MaestroGameplayScreen(
      isConnected: isConnected,
      title: challengeName,
      xp: 0,
      progress: progress,
      activeHardwareNote: activeHardwareNote,
      comboCount: comboCount,
      onClose: () => Navigator.of(context).maybePop(),
    );
  }
}