import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/domain/entities/operating_mode.dart';
import 'package:melody_sense/core/network/websocket_service.dart';
import 'package:melody_sense/core/providers/operating_mode_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/providers/websocket_providers.dart';
import 'package:melody_sense/core/widgets/maestro_gameplay_screen.dart';

/// Challenge / Gameplay — Maestro Mode (Smart Piano ESP32 Hardware).
///
/// Merender UI [MaestroGameplayScreen] secara reaktif terhubung ke WebSocket ESP32.
/// Tuts piano di layar menyala secara real-time saat tombol fisik ESP32 ditekan!
class MaestroChallengeScreen extends ConsumerStatefulWidget {
  const MaestroChallengeScreen({
    super.key,
    this.challengeName = 'C Major Arpeggio',
  });

  final String challengeName;

  @override
  ConsumerState<MaestroChallengeScreen> createState() =>
      _MaestroChallengeScreenState();
}

class _MaestroChallengeScreenState
    extends ConsumerState<MaestroChallengeScreen> {
  String? _activeHardwareNote;
  Timer? _noteHighlightTimer;
  StreamSubscription<String>? _noteSub;
  int _comboCount = 0;

  @override
  void initState() {
    super.initState();
    final wsService = ref.read(webSocketServiceProvider);
    _noteSub = wsService.noteStream.listen((note) {
      _onHardwareNoteReceived(note);
    });
  }

  @override
  void dispose() {
    _noteSub?.cancel();
    _noteHighlightTimer?.cancel();
    super.dispose();
  }

  void _onHardwareNoteReceived(String note) {
    // TTS hanya aktif di Sense Mode
    final mode = ref.read(operatingModeProvider);
    if (mode == AppOperatingMode.sense) {
      ref.read(ttsServiceProvider).speak('Nada $note');
    }

    _noteHighlightTimer?.cancel();
    setState(() {
      _activeHardwareNote = note;
      _comboCount += 1;
    });

    _noteHighlightTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _activeHardwareNote = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectionStateAsync = ref.watch(webSocketConnectionStateProvider);
    final wsService = ref.watch(webSocketServiceProvider);

    final connectionState = connectionStateAsync.maybeWhen(
      data: (s) => s,
      orElse: () => wsService.connectionState,
    );

    final isConnected = connectionState == WebSocketConnectionState.connected;

    return MaestroGameplayScreen(
      isConnected: isConnected,
      title: widget.challengeName,
      subtitle: isConnected
          ? 'Tekan tombol fisik Smart Piano untuk memainkan nada'
          : 'Smart Piano terputus. Sambungkan via Dashboard.',
      xp: _comboCount * 10,
      progress: (_comboCount / 20).clamp(0.0, 1.0),
      activeHardwareNote: _activeHardwareNote,
      comboCount: _comboCount > 0 ? _comboCount : null,
      onClose: () => Navigator.of(context).maybePop(),
    );
  }
}