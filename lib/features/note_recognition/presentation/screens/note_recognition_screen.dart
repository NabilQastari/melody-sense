import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/widgets/explorer_gameplay_screen.dart';
import 'package:melody_sense/core/widgets/session_result_screen.dart';

import '../controllers/note_recognition_controller.dart';
import '../state/note_recognition_state.dart';

/// Note Recognition — Explorer Mode (Mendukung Multi-Submode).
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
  String? _guidedHintNote;
  int _lastRoundIndex = -1;

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
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
              retryScreenBuilder: (_) => NoteRecognitionScreen(submode: widget.submode),
            ),
          ),
        );
      });
    }

    // Lacak pergantian ronde untuk mereset timer petunjuk (hint)
    if (state.roundIndex != _lastRoundIndex) {
      _lastRoundIndex = state.roundIndex;
      _resetHintTimer(state);
    }

    // Jika user sudah menekan jawaban, hilangkan hint
    if (state.feedback != RoundFeedback.none) {
      _hintTimer?.cancel();
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
      // Tampilkan hint dengan menyalakan tuts target berwarna hijau
      correctNote = _guidedHintNote;
    }

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
