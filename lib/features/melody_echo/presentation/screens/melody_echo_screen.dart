import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/domain/entities/operating_mode.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/network/websocket_service.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/operating_mode_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/providers/websocket_providers.dart';
import 'package:melody_sense/core/widgets/explorer_gameplay_screen.dart';
import 'package:melody_sense/core/widgets/maestro_gameplay_screen.dart';
import 'package:melody_sense/core/widgets/session_result_screen.dart';

import '../controllers/melody_echo_controller.dart';
import '../state/melody_echo_state.dart';

/// Melody Echo — Support Multi-Mode (Explorer, Maestro, & Sense).
///
/// Pengguna mendengarkan melodi (urutan nada), lalu mengulanginya
/// menggunakan piano virtual atau tuts fisik ESP32.
class MelodyEchoScreen extends ConsumerStatefulWidget {
  const MelodyEchoScreen({
    super.key,
    this.submode = PracticeSubmode.practice,
  });

  final PracticeSubmode submode;

  @override
  ConsumerState<MelodyEchoScreen> createState() => _MelodyEchoScreenState();
}

class _MelodyEchoScreenState extends ConsumerState<MelodyEchoScreen> {
  Timer? _hintTimer;
  Timer? _senseAutoPlayTimer;
  Timer? _hardwareHighlightTimer;
  StreamSubscription<String>? _noteSub;
  String? _guidedHintNote;
  String? _activeHardwareNote;
  int _lastRoundIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mode = ref.read(operatingModeProvider);

      if (mode == AppOperatingMode.sense) {
        ref.read(ttsServiceProvider).speak('Melody Echo. Dengarkan melodi lalu ulangi.');
      }

      if (mode != AppOperatingMode.explorer) {
        final wsService = ref.read(webSocketServiceProvider);
        _noteSub = wsService.noteStream.listen((note) {
          ref.read(melodyEchoControllerProvider(widget.submode).notifier).submitNote(note);
          _hardwareHighlightTimer?.cancel();
          setState(() => _activeHardwareNote = note);
          _hardwareHighlightTimer = Timer(const Duration(milliseconds: 250), () {
            if (mounted) setState(() => _activeHardwareNote = null);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _noteSub?.cancel();
    _hintTimer?.cancel();
    _senseAutoPlayTimer?.cancel();
    _hardwareHighlightTimer?.cancel();
    super.dispose();
  }

  void _startSenseAutoPlayTimer() {
    _senseAutoPlayTimer?.cancel();
    final mode = ref.read(operatingModeProvider);
    if (mode == AppOperatingMode.sense) {
      _senseAutoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted) return;
        final state = ref.read(melodyEchoControllerProvider(widget.submode));
        if (state != null && !state.isSessionOver && state.phase == MelodyEchoPhase.playing) {
          ref.read(melodyEchoControllerProvider(widget.submode).notifier).replayMelody();
        }
      });
    }
  }

  void _resetHintTimer(MelodyEchoState state) {
    _hintTimer?.cancel();
    _guidedHintNote = null;

    if (widget.submode == PracticeSubmode.guided &&
        state.phase == MelodyEchoPhase.playing &&
        !state.isSessionOver) {
      _hintTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && state.nextExpectedNote != null) {
          setState(() {
            _guidedHintNote = state.nextExpectedNote;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioReady = ref.watch(audioReadyProvider);
    final state = ref.watch(melodyEchoControllerProvider(widget.submode));
    final controller =
        ref.read(melodyEchoControllerProvider(widget.submode).notifier);
    final mode = ref.watch(operatingModeProvider);

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
      _senseAutoPlayTimer?.cancel();
      final completion = state.completion!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        if (mode == AppOperatingMode.sense) {
          final accuracy = (state.accuracy * 100).toInt();
          ref.read(ttsServiceProvider).speak('Sesi selesai. Akurasi $accuracy persen.');
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SessionResultScreen(
              isWin: state.isWin,
              accuracy: state.accuracy,
              xpEarned: state.xp,
              streakDays: completion.streakDays,
              leveledUp: completion.leveledUp,
              retryScreenBuilder: (_) =>
                  MelodyEchoScreen(submode: widget.submode),
            ),
          ),
        );
      });
    }

    // Lacak pergantian ronde untuk mereset timer petunjuk (hint) & auto play
    if (state.roundIndex != _lastRoundIndex) {
      _lastRoundIndex = state.roundIndex;
      _resetHintTimer(state);
      _startSenseAutoPlayTimer();
      if (mode == AppOperatingMode.sense) {
        ref.read(ttsServiceProvider).speak('Ronde ${state.roundIndex + 1}. Dengarkan melodi ${state.melodyLength} nada.');
      }
    }

    // Jika fase bukan playing, hilangkan hint & sense timer
    if (state.phase != MelodyEchoPhase.playing) {
      _hintTimer?.cancel();
      _senseAutoPlayTimer?.cancel();
      _guidedHintNote = null;
    }

    String? correctNote;
    String? wrongNote;

    if (state.feedback == RoundFeedback.correct) {
      correctNote = state.userInputs.isNotEmpty ? state.userInputs.last : null;
    } else if (state.feedback == RoundFeedback.wrong) {
      correctNote = state.nextExpectedNote;
      wrongNote = state.userInputs.isNotEmpty ? state.userInputs.last : null;
    } else if (_guidedHintNote != null) {
      correctNote = _guidedHintNote;
    }

    String targetLabel;
    String targetValue;

    switch (state.phase) {
      case MelodyEchoPhase.listening:
        targetLabel = 'Dengarkan melodi...';
        targetValue = '${state.melodyLength} Nada';
        break;
      case MelodyEchoPhase.playing:
        targetLabel = widget.submode == PracticeSubmode.guided
            ? 'Guided Practice (Ulangi Melodi)'
            : 'Giliranmu! Ulangi melodi';
        targetValue = '${state.currentInputIndex} / ${state.melodyLength}';
        break;
      case MelodyEchoPhase.feedback:
        targetLabel = state.feedback == RoundFeedback.correct
            ? 'Hebat!'
            : 'Coba Perhatikan...';
        targetValue = '${state.melodyLength} Nada';
        break;
    }

    // RENDER SENSE / MAESTRO GAMEPLAY SHELL (HARDWARE ESP32)
    if (mode == AppOperatingMode.maestro || mode == AppOperatingMode.sense) {
      final connectionStateAsync = ref.watch(webSocketConnectionStateProvider);
      final wsService = ref.watch(webSocketServiceProvider);
      final isConnected = (connectionStateAsync.value ?? wsService.connectionState) == WebSocketConnectionState.connected;

      return MaestroGameplayScreen(
        isConnected: isConnected,
        title: mode == AppOperatingMode.sense ? 'Sense Mode — Melody Echo' : 'Maestro Mode — Melody Echo',
        subtitle: 'Dengarkan melodi lalu tekan tuts di ESP32',
        targetLabel: targetLabel,
        targetValue: targetValue,
        correctNote: correctNote,
        wrongNote: wrongNote,
        showPianoLabels: true,
        xp: state.xp,
        progress: state.progress,
        activeHardwareNote: _activeHardwareNote,
        onAutoPlay: controller.replayMelody,
        isPlaying: state.isPlaying,
        feedback: state.feedback,
        roundIndex: state.roundIndex,
        totalRounds: state.totalRounds,
        onClose: () => Navigator.of(context).maybePop(),
      );
    }

    return ExplorerGameplayScreen(
      targetLabel: targetLabel,
      targetValue: targetValue,
      xp: state.xp,
      livesTotal: state.livesTotal,
      livesRemaining: state.livesRemaining,
      progress: state.progress,
      sequenceNotes: state.phase == MelodyEchoPhase.listening
          ? const []
          : state.userInputs,
      correctNote: correctNote,
      wrongNote: wrongNote,
      feedback: state.feedback,
      roundIndex: state.roundIndex,
      totalRounds: state.totalRounds,
      isPlaying: state.isPlaying,
      onClose: () => Navigator.of(context).maybePop(),
      onAutoPlay: controller.replayMelody,
      onNotePressed: controller.submitNote,
    );
  }
}