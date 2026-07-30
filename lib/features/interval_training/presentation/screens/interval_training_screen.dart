import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/widgets/explorer_gameplay_screen.dart';
import 'package:melody_sense/core/widgets/session_result_screen.dart';
import 'package:melody_sense/core/theme/app_colors.dart';

import '../controllers/interval_training_controller.dart';
import '../state/interval_training_state.dart';

/// Interval Training — Explorer Mode (Mendukung Multi-Submode & Kontrol Transisi Manual).
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
  String? _guidedRootHint;
  String? _guidedTargetHint;
  int _lastRoundIndex = -1;

  @override
  void dispose() {
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
      // Tahap 1: Detik ke-3, sorot Root Note (jangkar awal)
      _rootHintTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _guidedRootHint = state.rootNote;
          });
        }
      });

      // Tahap 2: Detik ke-6, sorot Target Note (jawaban yang benar)
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

    // Lacak pergantian ronde untuk mereset timer petunjuk (hint)
    if (state.roundIndex != _lastRoundIndex) {
      _lastRoundIndex = state.roundIndex;
      _resetHintTimers(state);
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
    String? activeNote = _guidedRootHint; // Sorot root note jika hint aktif
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