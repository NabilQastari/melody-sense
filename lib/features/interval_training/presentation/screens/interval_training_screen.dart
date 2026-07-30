import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:melody_sense/core/domain/entities/operating_mode.dart';
import 'package:melody_sense/core/network/websocket_service.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/operating_mode_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/providers/websocket_providers.dart';
import 'package:melody_sense/core/widgets/explorer_gameplay_screen.dart';
import 'package:melody_sense/core/widgets/maestro_gameplay_screen.dart';
import 'package:melody_sense/core/widgets/session_result_screen.dart';
import 'package:melody_sense/core/theme/app_colors.dart';

import '../controllers/interval_training_controller.dart';
import '../state/interval_training_state.dart';

/// Interval Training — Mendukung 3 Mode Utama (Explorer, Maestro, Sense).
class IntervalTrainingScreen extends ConsumerStatefulWidget {
  const IntervalTrainingScreen({
    super.key,
    this.submode = PracticeSubmode.practice,
  });

  final PracticeSubmode submode;

  @override
  ConsumerState<IntervalTrainingScreen> createState() => _IntervalTrainingScreenState();
}

class _IntervalTrainingScreenState extends ConsumerState<IntervalTrainingScreen> {
  Timer? _rootHintTimer;
  Timer? _targetHintTimer;
  StreamSubscription<String>? _noteSub;
  String? _guidedRootHint;
  String? _guidedTargetHint;
  int _lastRoundIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mode = ref.read(operatingModeProvider);
      if (mode != AppOperatingMode.explorer) {
        final wsService = ref.read(webSocketServiceProvider);
        _noteSub = wsService.noteStream.listen((note) {
          ref.read(intervalTrainingControllerProvider(widget.submode).notifier).submitAnswer(note);
        });
      }
    });
  }

  @override
  void dispose() {
    _noteSub?.cancel();
    _rootHintTimer?.cancel();
    _targetHintTimer?.cancel();
    super.dispose();
  }

  void _resetHintTimers(IntervalTrainingState state) {
    _rootHintTimer?.cancel();
    _targetHintTimer?.cancel();
    _guidedRootHint = null;
    _guidedTargetHint = null;

    if (widget.submode == PracticeSubmode.guided &&
        state.feedback == RoundFeedback.none &&
        !state.isSessionOver) {
      _rootHintTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _guidedRootHint = state.rootNote;
          });
        }
      });

      _targetHintTimer = Timer(const Duration(seconds: 6), () {
        if (mounted) {
          setState(() {
            _guidedTargetHint = state.targetNote;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioReady = ref.watch(audioReadyProvider);
    final state = ref.watch(intervalTrainingControllerProvider(widget.submode));
    final controller = ref.read(intervalTrainingControllerProvider(widget.submode).notifier);
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
              retryScreenBuilder: (_) => IntervalTrainingScreen(submode: widget.submode),
            ),
          ),
        );
      });
    }

    // Lacak pergantian ronde untuk mereset timer petunjuk (hint) & narasi TTS
    if (state.roundIndex != _lastRoundIndex) {
      _lastRoundIndex = state.roundIndex;
      _resetHintTimers(state);
      if (mode == AppOperatingMode.sense) {
        ref.read(ttsServiceProvider).speak(
              'Ronde ${state.roundIndex + 1}. Tebak jarak interval nada.',
            );
      }
    }

    // Jika user sudah menjawab, hilangkan hint
    final isTransitioning = state.feedback != RoundFeedback.none;
    if (isTransitioning) {
      _rootHintTimer?.cancel();
      _targetHintTimer?.cancel();
      _guidedRootHint = null;
      _guidedTargetHint = null;
    }

    final isWrong = state.feedback == RoundFeedback.wrong;

    String? correctNote;
    String? wrongNote;
    String? activeNote = _guidedRootHint;

    if (state.feedback == RoundFeedback.correct) {
      correctNote = state.lastPressedNote;
    } else if (isWrong) {
      correctNote = state.targetNote;
      wrongNote = state.lastPressedNote;
    } else if (_guidedTargetHint != null) {
      correctNote = _guidedTargetHint;
    }

    // RENDER SENSE / MAESTRO GAMEPLAY SHELL (HARDWARE ESP32)
    if (mode == AppOperatingMode.maestro || mode == AppOperatingMode.sense) {
      final connectionStateAsync = ref.watch(webSocketConnectionStateProvider);
      final wsService = ref.watch(webSocketServiceProvider);
      final isConnected = (connectionStateAsync.value ?? wsService.connectionState) == WebSocketConnectionState.connected;

      return MaestroGameplayScreen(
        isConnected: isConnected,
        title: mode == AppOperatingMode.sense ? 'Sense Mode — Interval Training' : 'Maestro Mode — Interval Training',
        subtitle: 'Dengarkan interval ${state.rootNote} lalu tekan nada target di ESP32',
        xp: state.xp,
        progress: state.progress,
        activeHardwareNote: state.lastPressedNote,
        comboCount: state.roundIndex > 0 ? state.roundIndex : null,
        onClose: () => Navigator.of(context).maybePop(),
      );
    }
    String? bridgeStartNote;
    String? bridgeEndNote;
    String? bridgeLabel;

    // Fase feedback (sudah dijawab)
    if (isTransitioning && state.lastPressedNote != null) {
      correctNote = state.targetNote;
      if (isWrong) {
        wrongNote = state.lastPressedNote;

        // Bridge: hubungkan rootNote ke jawaban salah untuk pembelajaran
        bridgeStartNote = state.rootNote;
        bridgeEndNote = state.lastPressedNote;

        final startSemitone = kSemitoneByNote[state.rootNote] ?? 0;
        final endSemitone = kSemitoneByNote[state.lastPressedNote!] ?? 0;
        final semitones = (endSemitone - startSemitone).abs();
        bridgeLabel = '$semitones semitone${semitones == 1 ? "" : "s"}';
      }
    } else if (_guidedTargetHint != null) {
      // Sorot target note jika hint detik ke-6 aktif
      correctNote = _guidedTargetHint;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ExplorerGameplayScreen(
            targetLabel: widget.submode == PracticeSubmode.guided 
                ? 'Guided Practice (Tebak Nada Kedua dari ${state.rootNote})' 
                : 'Mulai dari ${state.rootNote} → Tebak Nada Kedua',
            targetValue: '${state.intervalName} (+${state.semitones} semitone${state.semitones == 1 ? "" : "s"})',
            xp: state.xp,
            livesTotal: state.livesTotal,
            livesRemaining: state.livesRemaining,
            progress: state.progress,
            sequenceNotes: const [],
            correctNote: correctNote,
            wrongNote: wrongNote,
            rootNote: state.rootNote,
            activeNote: activeNote,
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
            onNotePressed: controller.submitAnswer,
          ),
          
          // Tombol Next Round melayang saat fase feedback transisi
          if (isTransitioning)
            Positioned(
              bottom: 235, // Tepat di atas area piano virtual
              child: ElevatedButton.icon(
                onPressed: controller.triggerNextRound,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.surfaceWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: AppColors.accent.withValues(alpha: 0.35),
                  elevation: 6,
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text(
                  'Lanjut Ronde',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ).animate().fadeIn(duration: 200.ms).scaleXY(begin: 0.9, end: 1.0),
            ),
        ],
      ),
    );
  }
}