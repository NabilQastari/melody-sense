import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/domain/entities/operating_mode.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/network/websocket_service.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/note_notation_provider.dart';
import 'package:melody_sense/core/providers/operating_mode_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/providers/websocket_providers.dart';
import 'package:melody_sense/core/widgets/explorer_gameplay_screen.dart';
import 'package:melody_sense/core/widgets/maestro_gameplay_screen.dart';
import 'package:melody_sense/core/widgets/session_result_screen.dart';

import '../controllers/note_recognition_controller.dart';
import '../state/note_recognition_state.dart';

/// Note Recognition — Mendukung 3 Mode Utama (Explorer, Maestro, Sense).
class NoteRecognitionScreen extends ConsumerStatefulWidget {
  const NoteRecognitionScreen({
    super.key,
    this.submode = PracticeSubmode.practice,
  });

  final PracticeSubmode submode;

  @override
  ConsumerState<NoteRecognitionScreen> createState() => _NoteRecognitionScreenState();
}

class _NoteRecognitionScreenState extends ConsumerState<NoteRecognitionScreen> {
  Timer? _hintTimer;
  Timer? _senseAutoPlayTimer;
  Timer? _hardwareHighlightTimer;
  StreamSubscription<String>? _noteSub;
  String? _guidedHintNote;
  String? _activeHardwareNote;
  int _lastRoundIndex = -1;
  RoundFeedback? _lastFeedback;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mode = ref.read(operatingModeProvider);

      // Narasi intro saat masuk layar dalam Sense Mode
      if (mode == AppOperatingMode.sense) {
        ref.read(ttsServiceProvider).speak('Pengenalan Nada. Tebak nada yang dimainkan.');
      }

      // Di Maestro dan Sense Mode, dengarkan input tombol fisik ESP32
      if (mode != AppOperatingMode.explorer) {
        final wsService = ref.read(webSocketServiceProvider);
        _noteSub = wsService.noteStream.listen((note) {
          ref.read(noteRecognitionControllerProvider(widget.submode).notifier).submitAnswer(note);
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

  /// Mulai timer 5 detik auto play khusus Sense Mode
  void _startSenseAutoPlayTimer() {
    _senseAutoPlayTimer?.cancel();
    final mode = ref.read(operatingModeProvider);
    if (mode == AppOperatingMode.sense) {
      _senseAutoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted) return;
        final state = ref.read(noteRecognitionControllerProvider(widget.submode));
        if (state != null && !state.isSessionOver && state.feedback == RoundFeedback.none) {
          final tts = ref.read(ttsServiceProvider);
          final notation = ref.read(noteNotationProvider);
          final spoken = tts.formatNoteForSpeech(state.targetNote, notation);
          tts.speak('Petunjuk nada: $spoken');
          ref.read(noteRecognitionControllerProvider(widget.submode).notifier).playTarget();
        }
      });
    }
  }

  /// Narasi TTS berurutan untuk Sense Mode saat ronde baru dimulai:
  /// 1. "Ronde {n}"
  /// 2. "Tekan nada {targetNote}"
  /// 3. Audio nada target diputar oleh controller
  void _speakRoundIntro(int roundIndex, String targetNote) {
    final tts = ref.read(ttsServiceProvider);
    final notation = ref.read(noteNotationProvider);
    final spokenNote = tts.formatNoteForSpeech(targetNote, notation);
    tts.speakSequence([
      'Ronde ${roundIndex + 1}',
      'Tekan nada $spokenNote',
    ]);
  }

  /// Narasi TTS saat feedback diberikan (benar/salah)
  void _speakFeedback(RoundFeedback feedback, String? pressedNote, String targetNote) {
    final tts = ref.read(ttsServiceProvider);
    final notation = ref.read(noteNotationProvider);
    final spokenTarget = tts.formatNoteForSpeech(targetNote, notation);
    if (feedback == RoundFeedback.correct) {
      tts.speak('Benar! $spokenTarget');
    } else if (feedback == RoundFeedback.wrong) {
      tts.speak('Salah. Jawaban yang benar adalah $spokenTarget');
    }
  }

  void _resetHintTimer(NoteRecognitionState state) {
    _hintTimer?.cancel();
    _guidedHintNote = null;

    if (widget.submode == PracticeSubmode.guided &&
        state.feedback == RoundFeedback.none &&
        !state.isSessionOver) {
      _hintTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _guidedHintNote = state.targetNote;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioReady = ref.watch(audioReadyProvider);
    final state = ref.watch(noteRecognitionControllerProvider(widget.submode));
    final controller = ref.read(noteRecognitionControllerProvider(widget.submode).notifier);
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
              retryScreenBuilder: (_) => NoteRecognitionScreen(submode: widget.submode),
            ),
          ),
        );
      });
    }

    // Lacak pergantian ronde & narasi TTS berurutan
    if (state.roundIndex != _lastRoundIndex) {
      _lastRoundIndex = state.roundIndex;
      _resetHintTimer(state);
      _startSenseAutoPlayTimer();
      if (mode == AppOperatingMode.sense) {
        _speakRoundIntro(state.roundIndex, state.targetNote);
      }
    }

    // Lacak feedback baru & narasi TTS
    if (state.feedback != RoundFeedback.none && state.feedback != _lastFeedback) {
      _lastFeedback = state.feedback;
      _senseAutoPlayTimer?.cancel();
      if (mode == AppOperatingMode.sense) {
        _speakFeedback(state.feedback, state.lastPressedNote, state.targetNote);
      }
    } else if (state.feedback == RoundFeedback.none) {
      _lastFeedback = null;
    }

    // Jika user sudah menekan jawaban, hilangkan hint
    if (state.feedback != RoundFeedback.none) {
      _hintTimer?.cancel();
      _senseAutoPlayTimer?.cancel();
      _guidedHintNote = null;
    }

    String? correctNote;
    String? wrongNote;

    if (state.feedback == RoundFeedback.correct) {
      correctNote = state.lastPressedNote;
    } else if (state.feedback == RoundFeedback.wrong) {
      correctNote = state.targetNote;
      wrongNote = state.lastPressedNote;
    } else if (_guidedHintNote != null) {
      correctNote = _guidedHintNote;
    }

    // RENDER SENSE / MAESTRO GAMEPLAY SHELL (HARDWARE ESP32)
    if (mode == AppOperatingMode.maestro || mode == AppOperatingMode.sense) {
      final connectionStateAsync = ref.watch(webSocketConnectionStateProvider);
      final wsService = ref.watch(webSocketServiceProvider);
      final isConnected = (connectionStateAsync.value ?? wsService.connectionState) == WebSocketConnectionState.connected;

      return MaestroGameplayScreen(
        isConnected: isConnected,
        title: mode == AppOperatingMode.sense ? 'Sense Mode — Note Recognition' : 'Maestro Mode — Note Recognition',
        subtitle: 'Tekan tombol fisik ESP32 untuk menebak nada target',
        targetLabel: widget.submode == PracticeSubmode.guided 
            ? 'Guided Practice (Tebak Nada)' 
            : 'Play the note',
        targetValue: state.targetNote,
        correctNote: correctNote,
        wrongNote: wrongNote,
        showPianoLabels: true,
        xp: state.xp,
        progress: state.progress,
        activeHardwareNote: _activeHardwareNote,
        comboCount: state.roundIndex > 0 ? state.roundIndex : null,
        onAutoPlay: () => controller.playTarget(),
        isPlaying: state.isPlaying,
        isMysteryRound: state.roundIndex == state.mysteryRoundIndex,
        feedback: state.feedback,
        roundIndex: state.roundIndex,
        totalRounds: state.totalRounds,
        onClose: () => Navigator.of(context).maybePop(),
      );
    }

    // RENDER EXPLORER GAMEPLAY SHELL (VIRTUAL TOUCH ONLY)
    return ExplorerGameplayScreen(
      targetLabel: widget.submode == PracticeSubmode.guided 
          ? 'Guided Practice (Tebak Nada)' 
          : 'Play the note',
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
