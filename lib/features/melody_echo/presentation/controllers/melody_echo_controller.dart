import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/audio/audio_service.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/domain/repositories/practice_repository.dart';
import 'package:melody_sense/core/domain/repositories/progression_repository.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/database_providers.dart';

import '../state/melody_echo_state.dart';

const _xpPerCorrectRound = 10;

/// Panjang melodi awal (ronde 1) dan pertambahan per 2 ronde.
const _initialMelodyLength = 3;
const _melodyGrowEveryNRounds = 2;
const _maxMelodyLength = 7;

/// Domain logic Melody Echo — "dengarkan melodi, lalu ulangi."
///
/// Pola controller identik dengan NoteRecognitionController:
/// - `StateNotifier.autoDispose` + start session di constructor
/// - Log attempt per nada, tutup sesi via `finishSession()` + `completeSession()`
/// - Dukung multi-submode (practice: pakai nyawa, guided: tanpa nyawa + hint)
class MelodyEchoController extends StateNotifier<MelodyEchoState?> {
  MelodyEchoController(this._ref, this.submode) : super(null) {
    _start();
  }

  final Ref _ref;
  final PracticeSubmode submode;
  final _random = Random();
  bool _isTransitioning = false;

  PracticeRepository get _practiceRepo =>
      _ref.read(practiceRepositoryProvider);
  ProgressionRepository get _progressionRepo =>
      _ref.read(progressionRepositoryProvider);
  AudioService get _audio => _ref.read(audioServiceProvider);

  /// Hitung panjang melodi berdasarkan ronde saat ini.
  /// Ronde 0-1: 3 nada, Ronde 2-3: 4 nada, dst. sampai max 7.
  int _melodyLengthForRound(int roundIndex) {
    final extra = roundIndex ~/ _melodyGrowEveryNRounds;
    return (_initialMelodyLength + extra).clamp(
      _initialMelodyLength,
      _maxMelodyLength,
    );
  }

  /// Generate melodi acak dari kAvailableNotes.
  /// Hindari 2 nada berturut-turut sama.
  List<String> _generateMelody(int length) {
    final melody = <String>[];
    for (var i = 0; i < length; i++) {
      String note;
      do {
        note = kAvailableNotes[_random.nextInt(kAvailableNotes.length)];
      } while (melody.isNotEmpty && note == melody.last);
      melody.add(note);
    }
    return melody;
  }

  Future<void> _start() async {
    _isTransitioning = false;
    await _progressionRepo.seedDefaultAchievementsIfEmpty();

    final sessionId = await _practiceRepo.startSession(
      TrainingMode.melodyEcho,
    );

    final melodyLength = _melodyLengthForRound(0);
    final melody = _generateMelody(melodyLength);

    int? livesTotal = 3;
    int? livesRemaining = 3;
    const totalRounds = 8;

    if (submode == PracticeSubmode.guided) {
      livesTotal = null;
      livesRemaining = null;
    }

    state = MelodyEchoState(
      melody: melody,
      sessionId: sessionId,
      submode: submode,
      livesTotal: livesTotal,
      livesRemaining: livesRemaining,
      totalRounds: totalRounds,
    );

    // Putar melodi setelah delay singkat agar UI sempat mount
    Future.delayed(const Duration(milliseconds: 600), () {
      _playMelody();
    });
  }

  /// Putar melodi target via AudioService.
  Future<void> _playMelody() async {
    if (!mounted) return;
    final current = state;
    if (current == null) return;

    state = current.copyWith(
      phase: MelodyEchoPhase.listening,
      isPlaying: true,
    );

    await _audio.playSequence(
      current.melody,
      gap: const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    state = state?.copyWith(
      phase: MelodyEchoPhase.playing,
      isPlaying: false,
      userInputs: [],
    );
  }

  /// User minta putar ulang melodi (Auto Play).
  Future<void> replayMelody() async {
    final current = state;
    if (current == null || _isTransitioning) return;
    if (current.phase == MelodyEchoPhase.feedback) return;

    await _playMelody();
  }

  /// User menekan tuts — cek apakah nada ke-N sesuai melodi[N].
  Future<void> submitNote(String note) async {
    final current = state;
    if (current == null ||
        current.isSessionOver ||
        _isTransitioning ||
        current.phase != MelodyEchoPhase.playing) {
      return;
    }

    _audio.playNote(note);

    final expectedNote = current.nextExpectedNote;
    if (expectedNote == null) return;

    final isCorrect = note == expectedNote;
    final newInputs = [...current.userInputs, note];

    // Log attempt untuk statistik per nada
    await _practiceRepo.logAttempt(
      sessionId: current.sessionId,
      note: note,
      isCorrect: isCorrect,
      responseTimeMs: 0, // Melody Echo tidak mengukur response time per nada
    );

    if (isCorrect) {
      state = current.copyWith(userInputs: newInputs);

      // Cek apakah user sudah mengulangi seluruh melodi
      if (newInputs.length >= current.melody.length) {
        // Ronde selesai — BENAR
        _isTransitioning = true;
        final addedXp = _xpPerCorrectRound;
        final nextXp = current.xp + addedXp;
        final nextCorrectCount = current.correctCount + 1;

        state = state?.copyWith(
          xp: nextXp,
          correctCount: nextCorrectCount,
          phase: MelodyEchoPhase.feedback,
          feedback: RoundFeedback.correct,
        );

        await Future.delayed(const Duration(milliseconds: 1200));
        if (!mounted) return;
        _advanceRound(nextXp, nextCorrectCount);
      }
    } else {
      // Ronde selesai — SALAH
      _isTransitioning = true;

      final nextLives = current.livesRemaining != null
          ? current.livesRemaining! - 1
          : null;

      state = current.copyWith(
        userInputs: newInputs,
        livesRemaining: nextLives,
        phase: MelodyEchoPhase.feedback,
        feedback: RoundFeedback.wrong,
      );

      // Compare playback: mainkan nada yang benar setelah delay
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _audio.playNote(expectedNote);
      });

      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) return;

      final afterLives = state?.livesRemaining;
      final sessionOver = afterLives != null && afterLives <= 0;

      if (sessionOver) {
        state = state?.copyWith(isSessionOver: true);
        await _finishSession(xpEarned: current.xp);
      } else {
        _advanceRound(current.xp, current.correctCount);
      }
    }
  }

  void _advanceRound(int currentXp, int currentCorrectCount) {
    final current = state;
    if (current == null) return;

    final nextRoundIndex = current.roundIndex + 1;

    // Cek apakah semua ronde selesai
    if (nextRoundIndex >= current.totalRounds) {
      state = current.copyWith(
        roundIndex: nextRoundIndex,
        isSessionOver: true,
      );
      _finishSession(xpEarned: currentXp);
      return;
    }

    // Generate melodi baru untuk ronde berikutnya
    final newLength = _melodyLengthForRound(nextRoundIndex);
    final newMelody = _generateMelody(newLength);

    state = current.copyWith(
      roundIndex: nextRoundIndex,
      melody: newMelody,
      userInputs: [],
      phase: MelodyEchoPhase.listening,
      feedback: RoundFeedback.none,
    );
    _isTransitioning = false;

    // Putar melodi baru
    _playMelody();
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
      mode: TrainingMode.melodyEcho,
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

final melodyEchoControllerProvider = StateNotifierProvider.family
    .autoDispose<MelodyEchoController, MelodyEchoState?, PracticeSubmode>(
  (ref, submode) => MelodyEchoController(ref, submode),
);
