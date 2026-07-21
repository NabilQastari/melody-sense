import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/audio/audio_service.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/domain/repositories/practice_repository.dart';
import 'package:melody_sense/core/domain/repositories/progression_repository.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/database_providers.dart';

import '../state/note_recognition_state.dart';

const _xpPerCorrect = 10;

/// Domain logic Note Recognition dengan dukungan multi submode.
class NoteRecognitionController extends StateNotifier<NoteRecognitionState?> {
  NoteRecognitionController(this._ref, this.submode) : super(null) {
    _start();
  }

  final Ref _ref;
  final PracticeSubmode submode;
  final _random = Random();
  DateTime? _roundStartedAt;
  bool _isTransitioning = false;

  PracticeRepository get _practiceRepo =>
      _ref.read(practiceRepositoryProvider);
  ProgressionRepository get _progressionRepo =>
      _ref.read(progressionRepositoryProvider);
  AudioService get _audio => _ref.read(audioServiceProvider);

  Future<void> _start() async {
    _isTransitioning = false;
    await _progressionRepo.seedDefaultAchievementsIfEmpty();

    final sessionId = await _practiceRepo.startSession(
      TrainingMode.noteRecognition,
    );
    final target = _pickNextNote();

    int? livesTotal = 3;
    int? livesRemaining = 3;
    int totalRounds = 10;

    if (submode == PracticeSubmode.guided) {
      livesTotal = null;
      livesRemaining = null;
      totalRounds = 10;
    }

    state = NoteRecognitionState(
      targetNote: target,
      sessionId: sessionId,
      mysteryRoundIndex: _random.nextInt(totalRounds),
      submode: submode,
      livesTotal: livesTotal,
      livesRemaining: livesRemaining,
      totalRounds: totalRounds,
    );
    _roundStartedAt = DateTime.now();

    // Putar nada target pertama setelah inisialisasi selesai & audio siap
    Future.delayed(const Duration(milliseconds: 500), () {
      _playNoteWithStatus(target);
    });
  }

  String _pickNextNote([String? avoid]) {
    String note;
    do {
      note = kAvailableNotes[_random.nextInt(kAvailableNotes.length)];
    } while (note == avoid && kAvailableNotes.length > 1);
    return note;
  }

  Future<void> _playNoteWithStatus(String note) async {
    if (!mounted) return;
    state = state?.copyWith(isPlaying: true);
    await _audio.playNote(note);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    state = state?.copyWith(isPlaying: false);
  }

  Future<void> playTarget() async {
    final current = state;
    if (current == null || _isTransitioning) return;
    await _playNoteWithStatus(current.targetNote);
  }

  Future<void> submitAnswer(String note) async {
    final current = state;
    if (current == null || current.isSessionOver || _isTransitioning) return;

    _isTransitioning = true;
    _audio.playNote(note);

    final isCorrect = note == current.targetNote;
    final responseTimeMs = _roundStartedAt == null
        ? 0
        : DateTime.now().difference(_roundStartedAt!).inMilliseconds;

    await _practiceRepo.logAttempt(
      sessionId: current.sessionId,
      note: note,
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
    );

    final isMystery = current.roundIndex == current.mysteryRoundIndex;
    final addedXp = isCorrect ? (isMystery ? _xpPerCorrect * 2 : _xpPerCorrect) : 0;
    final nextXp = current.xp + addedXp;

    final nextLives = current.livesRemaining != null
        ? (isCorrect ? current.livesRemaining! : current.livesRemaining! - 1)
        : null;

    final nextCorrectCount = isCorrect ? current.correctCount + 1 : current.correctCount;
    final sessionOver = (nextLives != null && nextLives <= 0) ||
        (current.roundIndex + 1) >= current.totalRounds;

    state = current.copyWith(
      xp: nextXp,
      livesRemaining: nextLives,
      correctCount: nextCorrectCount,
      feedback: isCorrect ? RoundFeedback.correct : RoundFeedback.wrong,
      lastPressedNote: note,
    );

    if (!isCorrect) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _audio.playSequence([current.targetNote, note], gap: const Duration(milliseconds: 500));
      });
    }

    final delayMs = isCorrect ? 1200 : 2000;
    await Future.delayed(Duration(milliseconds: delayMs));

    if (!mounted) return;

    if (sessionOver) {
      state = state?.copyWith(isSessionOver: true);
      await _finishSession(xpEarned: nextXp);
    } else {
      final nextRoundIndex = current.roundIndex + 1;
      final nextNote = _pickNextNote(current.targetNote);
      state = state?.copyWith(
        roundIndex: nextRoundIndex,
        targetNote: nextNote,
        feedback: RoundFeedback.none,
        lastPressedNote: null,
      );
      _roundStartedAt = DateTime.now();
      _isTransitioning = false;

      _playNoteWithStatus(nextNote);
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
      mode: TrainingMode.noteRecognition,
      score: score,
      xpEarnedThisSession: xpEarned,
      correctCount: current.correctCount,
      totalRounds: current.totalRounds,
    );

    if (!mounted) return;
    state = state?.copyWith(completion: completion);
  }

  Future<void> restart() => _start();
}

final noteRecognitionControllerProvider = StateNotifierProvider.family
    .autoDispose<NoteRecognitionController, NoteRecognitionState?, PracticeSubmode>(
  (ref, submode) => NoteRecognitionController(ref, submode),
);
