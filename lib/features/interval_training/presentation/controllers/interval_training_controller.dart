import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/audio/audio_service.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/domain/repositories/practice_repository.dart';
import 'package:melody_sense/core/domain/repositories/progression_repository.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/database_providers.dart';

import '../state/interval_training_state.dart';

/// XP tetap per jawaban benar — sama seperti Note Recognition. Nilai
/// terpisah (bukan konstanta bersama) sesuai pola yang sudah ada, biar
/// gampang dibedakan balancing-nya per mode nanti kalau perlu.
const _xpPerCorrect = 10;

/// Domain logic Interval Training — pola sama persis dengan
/// [NoteRecognitionController] (Sesi 4-5): generate ronde, cek jawaban,
/// log attempt, tutup sesi lewat completeSession().
///
/// Bedanya cuma cara generate target: bukan 1 nada tunggal acak, tapi
/// pasangan (root note, interval) dari [kValidIntervalRounds]. Root
/// note diperdengarkan (lewat [playSequence]), lalu user harus menebak
/// nada kedua yang membentuk interval yang diminta dengan menekan tuts
/// piano yang sesuai — dicek di [submitAnswer] sama seperti cara
/// Note Recognition mencocokkan tuts yang ditekan dengan targetNote.
class IntervalTrainingController
    extends StateNotifier<IntervalTrainingState?> {
  IntervalTrainingController(this._ref) : super(null) {
    _start();
  }

  final Ref _ref;
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
    // Idempotent, sama seperti NoteRecognitionController — lihat
    // catatan di sana soal kenapa dipanggil di titik ini.
    await _progressionRepo.seedDefaultAchievementsIfEmpty();

    final sessionId = await _practiceRepo.startSession(
      TrainingMode.intervalTraining,
    );
    final mysteryIndex = _random.nextInt(10);
    state = IntervalTrainingState(
      currentRound: _pickNextRound(),
      sessionId: sessionId,
      mysteryRoundIndex: mysteryIndex,
    );
    _roundStartedAt = DateTime.now();

    // Auto-play interval di awal sesi
    Future.delayed(const Duration(milliseconds: 300), () {
      playSequence();
    });
  }

  /// Pilih kombinasi root+interval acak dari [kValidIntervalRounds],
  /// hindari root+interval yang sama persis dengan ronde sebelumnya
  /// (biar tidak terasa berulang) — pola sama seperti _pickNextNote
  /// di Note Recognition.
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

  /// Dipanggil dari tombol Auto Play — memutar root note lalu target
  /// note berurutan ("Listen to the sequence..." di desain). User
  /// mendengar kedua nada, lalu harus menebak nada kedua di piano.
  Future<void> playSequence() async {
    final current = state;
    if (current == null || current.isPlaying) return;
    await _playSequenceWithStatus([current.rootNote, current.targetNote]);
  }

  Future<void> _playSequenceWithStatus(List<String> notes) async {
    if (!mounted) return;
    state = state?.copyWith(isPlaying: true);
    await _audio.playSequence(notes);
    if (!mounted) return;
    state = state?.copyWith(isPlaying: false);
  }

  /// Dipanggil setiap kali user menekan tuts piano — dianggap sebagai
  /// jawaban (nada kedua yang ditebak), sama seperti submitAnswer di
  /// Note Recognition.
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

    final nextLives =
        isCorrect ? current.livesRemaining : current.livesRemaining - 1;
    final nextXp = current.xp + xpEarned;
    final nextRoundIndex = current.roundIndex + 1;
    final nextCorrectCount =
        isCorrect ? current.correctCount + 1 : current.correctCount;
    final sessionOver =
        nextLives <= 0 || nextRoundIndex >= current.totalRounds;

    state = current.copyWith(
      xp: nextXp,
      livesRemaining: nextLives,
      feedback: isCorrect ? RoundFeedback.correct : RoundFeedback.wrong,
      lastPressedNote: note,
    );

    if (!isCorrect) {
      // Compare Playback: target interval -> jeda -> user chosen interval
      Future.delayed(const Duration(milliseconds: 600), () async {
        if (!mounted) return;
        await _audio.playSequence([current.rootNote, current.targetNote]);
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        await _audio.playSequence([current.rootNote, note]);
      });
    }

    final delay = isCorrect
        ? const Duration(milliseconds: 1200)
        : const Duration(milliseconds: 3200);

    await Future.delayed(delay);
    if (!mounted) return;

    if (sessionOver) {
      state = state?.copyWith(
        roundIndex: nextRoundIndex,
        correctCount: nextCorrectCount,
        isSessionOver: true,
      );
      await _finishSession(xpEarned: nextXp);
    } else {
      final nextRound = _pickNextRound(current.currentRound);
      state = state?.copyWith(
        roundIndex: nextRoundIndex,
        correctCount: nextCorrectCount,
        feedback: RoundFeedback.none,
        lastPressedNote: null,
        currentRound: nextRound,
      );
      _roundStartedAt = DateTime.now();
      _isTransitioning = false;
      // Auto-play interval untuk ronde berikutnya
      playSequence();
    }
  }

  Future<void> _finishSession({required int xpEarned}) async {
    final current = state;
    if (current == null) return;

    // Skor sederhana = XP sesi ini, sama seperti Note Recognition.
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

  /// Mulai sesi baru dari awal. Sama seperti Note Recognition, provider
  /// autoDispose sudah menghandle ini otomatis lewat tombol Retry, jadi
  /// method ini disiapkan tapi belum tentu dipanggil manual dari UI.
  Future<void> restart() => _start();
}

final intervalTrainingControllerProvider = StateNotifierProvider.autoDispose<
    IntervalTrainingController, IntervalTrainingState?>(
  (ref) => IntervalTrainingController(ref),
);