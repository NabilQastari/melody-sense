import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/audio/audio_service.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/domain/repositories/practice_repository.dart';
import 'package:melody_sense/core/domain/repositories/progression_repository.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/database_providers.dart';

import '../state/interval_training_state.dart';

const _xpPerCorrect = 10;

class IntervalTrainingController extends StateNotifier<IntervalTrainingState?> {
  IntervalTrainingController(this._ref, this.submode) : super(null) {
    _start();
  }

  final Ref _ref;
  final PracticeSubmode submode;
  final _random = Random();
  DateTime? _roundStartedAt;
  bool _isTransitioning = false;
  Timer? _transitionTimer;

  PracticeRepository get _practiceRepo =>
      _ref.read(practiceRepositoryProvider);
  ProgressionRepository get _progressionRepo =>
      _ref.read(progressionRepositoryProvider);
  AudioService get _audio => _ref.read(audioServiceProvider);

  @override
  void dispose() {
    _transitionTimer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    _isTransitioning = false;
    _transitionTimer?.cancel();
    await _progressionRepo.seedDefaultAchievementsIfEmpty();

    final sessionId = await _practiceRepo.startSession(
      TrainingMode.intervalTraining,
    );

    int? livesTotal = 3;
    int? livesRemaining = 3;
    int totalRounds = 10;

    if (submode == PracticeSubmode.guided) {
      livesTotal = null;
      livesRemaining = null;
      totalRounds = 10;
    }

    final mysteryIndex = _random.nextInt(totalRounds);
    state = IntervalTrainingState(
      currentRound: _pickNextRound(),
      sessionId: sessionId,
      mysteryRoundIndex: mysteryIndex,
      submode: submode,
      livesTotal: livesTotal,
      livesRemaining: livesRemaining,
      totalRounds: totalRounds,
    );
    _roundStartedAt = DateTime.now();

    // Auto-play interval di awal sesi
    Future.delayed(const Duration(milliseconds: 300), () {
      playSequence();
    });
  }

  IntervalRoundOption _pickNextRound([IntervalRoundOption? avoid]) {
    IntervalRoundOption option;
    do {
      option =
          kValidIntervalRounds[_random.nextInt(kValidIntervalRounds.length)];
    } while (avoid != null &&
        option.rootNote == avoid.rootNote &&
        option.intervalName == avoid.intervalName &&
        kValidIntervalRounds.length > 1);
    return option;
  }

  Future<void> playSequence() async {
    final current = state;
    if (current == null || current.isPlaying) return;
    await _playSequenceWithStatus([current.rootNote, current.targetNote]);
  }

  Future<void> playTarget() => playSequence();

  Future<void> _playSequenceWithStatus(List<String> notes) async {
    if (!mounted) return;
    state = state?.copyWith(isPlaying: true);
    await _audio.playSequence(notes);
    if (!mounted) return;
    state = state?.copyWith(isPlaying: false);
  }

  Future<void> submitAnswer(String note) async {
    final current = state;
    if (current == null || current.isSessionOver || _isTransitioning) return;

    _isTransitioning = true;
    _audio.playNote(note);

    final isCorrect = note == current.targetNote;
    final isMystery = current.roundIndex == current.mysteryRoundIndex;
    final xpEarned = isCorrect ? (isMystery ? 20 : _xpPerCorrect) : 0;

    final responseTimeMs = _roundStartedAt == null
        ? 0
        : DateTime.now().difference(_roundStartedAt!).inMilliseconds;

    await _practiceRepo.logAttempt(
      sessionId: current.sessionId,
      note: note,
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
    );

    final nextLives = current.livesRemaining != null
        ? (isCorrect ? current.livesRemaining! : current.livesRemaining! - 1)
        : null;
    final nextXp = current.xp + xpEarned;
    final nextCorrectCount =
        isCorrect ? current.correctCount + 1 : current.correctCount;

    state = current.copyWith(
      xp: nextXp,
      livesRemaining: nextLives,
      correctCount: nextCorrectCount,
      feedback: isCorrect ? RoundFeedback.correct : RoundFeedback.wrong,
      lastPressedNote: note,
    );

    if (!isCorrect) {
      Future.delayed(const Duration(milliseconds: 600), () async {
        if (!mounted) return;
        await _audio.playSequence([current.rootNote, current.targetNote]);
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        await _audio.playSequence([current.rootNote, note]);
      });
    }

    final delayMs = isCorrect ? 1200 : 3200;
    _transitionTimer = Timer(Duration(milliseconds: delayMs), () {
      _performTransition();
    });
  }

  /// Langsung melompati delay transisi ronde berikutnya saat fase feedback.
  void triggerNextRound() {
    if (!_isTransitioning || state == null || state!.isSessionOver) return;
    _transitionTimer?.cancel();
    _transitionTimer = null;
    _performTransition();
  }

  Future<void> _performTransition() async {
    final current = state;
    if (current == null) return;

    final sessionOver = (current.livesRemaining != null && current.livesRemaining! <= 0) ||
        (current.roundIndex + 1) >= current.totalRounds;

    if (sessionOver) {
      state = state?.copyWith(
        roundIndex: current.roundIndex + 1,
        isSessionOver: true,
      );
      await _finishSession(xpEarned: current.xp);
    } else {
      final nextRound = _pickNextRound(current.currentRound);
      state = state?.copyWith(
        roundIndex: current.roundIndex + 1,
        feedback: RoundFeedback.none,
        lastPressedNote: null,
        currentRound: nextRound,
      );
      _roundStartedAt = DateTime.now();
      _isTransitioning = false;
      playSequence();
    }
  }

  Future<void> _finishSession({required int xpEarned}) async {
    final current = state;
    if (current == null) return;

    final score = xpEarned;

    await _practiceRepo.finishSession(
      sessionId: current.sessionId,
      xpEarned: xpEarned,
      score: score,
    );

    final completion = await _progressionRepo.completeSession(
      mode: TrainingMode.intervalTraining,
      score: score,
      xpEarnedThisSession: xpEarned,
      correctCount: current.correctCount,
      totalRounds: current.totalRounds,
    );

    state = state?.copyWith(completion: completion);
  }

  Future<void> restart() => _start();
}

final intervalTrainingControllerProvider = StateNotifierProvider.family
    .autoDispose<IntervalTrainingController, IntervalTrainingState?, PracticeSubmode>(
  (ref, submode) => IntervalTrainingController(ref, submode),
);