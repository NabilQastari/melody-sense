import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/audio/audio_service.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/domain/repositories/practice_repository.dart';
import 'package:melody_sense/core/domain/repositories/progression_repository.dart';
import 'package:melody_sense/features/note_recognition/presentation/state/note_recognition_state.dart'
    show kAvailableNotes, RoundFeedback;
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/database_providers.dart';

import '../state/rhythm_match_state.dart';

const _xpPerCorrect = 10;

/// Domain logic Rhythm Match — pola dasarnya sama dengan
/// NoteRecognitionController/IntervalTrainingController (generate
/// ronde, cek jawaban, log attempt, tutup sesi lewat completeSession()),
/// TAPI ada satu elemen baru: waktu berjalan.
///
/// Tiap ronde punya "beat target" (kapan seharusnya user menekan tuts)
/// dan jendela toleransi [kHitWindowMs]. Ada dua jalur yang bisa
/// mengakhiri satu ronde:
/// 1. User menekan tuts lewat [submitTap] — dicek nada DAN timing-nya.
/// 2. Jendela waktu habis tanpa ada tap sama sekali — [_handleTimeout]
///    dipanggil otomatis lewat Timer, dihitung Miss.
///
/// Karena ada Timer yang berjalan di background, controller ini WAJIB
/// meng-override [dispose] untuk membatalkannya — kalau tidak, Timer
/// bisa terus jalan dan mencoba update state setelah controller-nya
/// sendiri sudah dibuang (mis. user keluar dari layar di tengah ronde).
class RhythmMatchController extends StateNotifier<RhythmMatchState?> {
  RhythmMatchController(this._ref) : super(null) {
    _start();
  }

  final Ref _ref;
  final _random = Random();

  Timer? _timeoutTimer;
  DateTime? _roundStartedAt;
  DateTime? _beatTargetAt;

  PracticeRepository get _practiceRepo =>
      _ref.read(practiceRepositoryProvider);
  ProgressionRepository get _progressionRepo =>
      _ref.read(progressionRepositoryProvider);
  AudioService get _audio => _ref.read(audioServiceProvider);

  Future<void> _start() async {
    await _progressionRepo.seedDefaultAchievementsIfEmpty();

    final sessionId = await _practiceRepo.startSession(
      TrainingMode.rhythmMatch,
    );
    state = RhythmMatchState(
      targetNote: _pickNextNote(),
      sessionId: sessionId,
    );
    _scheduleRound();
  }

  String _pickNextNote([String? avoid]) {
    String note;
    do {
      note = kAvailableNotes[_random.nextInt(kAvailableNotes.length)];
    } while (note == avoid && kAvailableNotes.length > 1);
    return note;
  }

  /// Menandai mulainya satu ronde: catat kapan ronde dimulai, hitung
  /// kapan beat target-nya, lalu jadwalkan timeout yang otomatis
  /// menghitung Miss kalau user tidak sempat tap sampai jendela
  /// toleransi berakhir.
  void _scheduleRound() {
    _timeoutTimer?.cancel();
    final now = DateTime.now();
    _roundStartedAt = now;
    _beatTargetAt = now.add(const Duration(milliseconds: kBeatIntervalMs));

    _timeoutTimer = Timer(
      const Duration(milliseconds: kBeatIntervalMs + kHitWindowMs),
      _handleTimeout,
    );
  }

  /// Dipanggil dari tombol Auto Play / kartu prompt — sekadar
  /// memperdengarkan ulang nada target, TIDAK dihitung sebagai
  /// tap/jawaban dan tidak mereset timer beat yang sedang berjalan.
  void playTarget() {
    final current = state;
    if (current == null) return;
    _audio.playNote(current.targetNote);
  }

  /// Dipanggil setiap kali user menekan tuts piano. Benar hanya kalau
  /// nada cocok DAN waktunya berada dalam [kHitWindowMs] dari beat
  /// target.
  Future<void> submitTap(String note) async {
    final current = state;
    if (current == null ||
        current.isSessionOver ||
        _beatTargetAt == null ||
        _roundStartedAt == null) {
      return;
    }

    _timeoutTimer?.cancel();
    _audio.playNote(note);

    final now = DateTime.now();
    final timingDiffMs = now.difference(_beatTargetAt!).inMilliseconds.abs();
    final isCorrect = note == current.targetNote && timingDiffMs <= kHitWindowMs;
    final responseTimeMs = now.difference(_roundStartedAt!).inMilliseconds;

    await _resolveRound(
      isCorrect: isCorrect,
      note: note,
      responseTimeMs: responseTimeMs,
    );
  }

  /// Dipanggil otomatis lewat Timer kalau user tidak tap sama sekali
  /// sampai jendela beat berakhir — otomatis Miss.
  Future<void> _handleTimeout() async {
    final current = state;
    if (current == null || current.isSessionOver) return;

    // Nada target dicatat sebagai attempt yang gagal (bukan nada
    // kosong) supaya statistik akurasi per nada tetap relevan —
    // ini mode gagal karena TIDAK tap, bukan tap nada lain.
    await _resolveRound(
      isCorrect: false,
      note: current.targetNote,
      responseTimeMs: kBeatIntervalMs + kHitWindowMs,
    );
  }

  Future<void> _resolveRound({
    required bool isCorrect,
    required String note,
    required int responseTimeMs,
  }) async {
    final current = state;
    if (current == null || current.isSessionOver) return;

    await _practiceRepo.logAttempt(
      sessionId: current.sessionId,
      note: note,
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
    );

    final nextLives =
        isCorrect ? current.livesRemaining : current.livesRemaining - 1;
    final nextXp = isCorrect ? current.xp + _xpPerCorrect : current.xp;
    final nextRoundIndex = current.roundIndex + 1;
    final nextCorrectCount =
        isCorrect ? current.correctCount + 1 : current.correctCount;
    final sessionOver =
        nextLives <= 0 || nextRoundIndex >= current.totalRounds;

    state = current.copyWith(
      xp: nextXp,
      livesRemaining: nextLives,
      roundIndex: nextRoundIndex,
      correctCount: nextCorrectCount,
      feedback: isCorrect ? RoundFeedback.correct : RoundFeedback.wrong,
      isSessionOver: sessionOver,
      targetNote: sessionOver
          ? current.targetNote
          : _pickNextNote(current.targetNote),
    );

    if (sessionOver) {
      await _finishSession(xpEarned: nextXp);
    } else {
      _scheduleRound();
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
      mode: TrainingMode.rhythmMatch,
      score: score,
      xpEarnedThisSession: xpEarned,
      correctCount: current.correctCount,
      totalRounds: current.totalRounds,
    );

    state = state?.copyWith(completion: completion);
  }

  Future<void> restart() => _start();

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }
}

final rhythmMatchControllerProvider = StateNotifierProvider.autoDispose<
    RhythmMatchController, RhythmMatchState?>(
  (ref) => RhythmMatchController(ref),
);