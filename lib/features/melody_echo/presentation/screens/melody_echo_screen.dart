import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/widgets/explorer_gameplay_screen.dart';
import 'package:melody_sense/core/widgets/session_result_screen.dart';

import '../controllers/melody_echo_controller.dart';
import '../state/melody_echo_state.dart';

/// Melody Echo — Explorer Mode (Mendukung Multi-Submode).
///
/// Pengguna mendengarkan melodi (urutan nada), lalu mengulanginya
/// menggunakan piano virtual.
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
  String? _guidedHintNote;
  int _lastRoundIndex = -1;

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
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
              retryScreenBuilder: (_) =>
                  MelodyEchoScreen(submode: widget.submode),
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

    // Jika fase bukan playing, hilangkan hint
    if (state.phase != MelodyEchoPhase.playing) {
      _hintTimer?.cancel();
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