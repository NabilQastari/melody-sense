import 'package:flutter/foundation.dart';

import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/domain/entities/progression_entities.dart';
import 'package:melody_sense/features/note_recognition/presentation/state/note_recognition_state.dart'
    show RoundFeedback;

/// Tempo tetap untuk MVP ini — 90 BPM. Belum ada UI metronome/visual
/// beat, jadi nilai ini baru dipakai buat hitung jendela waktu di
/// controller. Kalau nanti mau tempo bervariasi per ronde (mis. makin
/// cepat makin sulit), tinggal ganti dari const jadi field di state.
const kRhythmMatchBpm = 90;

/// Interval antar beat dalam milidetik, diturunkan dari [kRhythmMatchBpm].
/// 90 BPM = 60000/90 ≈ 667ms per ketukan.
const kBeatIntervalMs = 60000 ~/ kRhythmMatchBpm;

/// Toleransi ketepatan tap terhadap waktu beat (±300ms dari beat target
/// dihitung Hit, di luar itu Miss). Biner — belum ada tier
/// Perfect/Good/Miss, bisa dikembangkan nanti.
const kHitWindowMs = 300;

@immutable
class RhythmMatchState {
  const RhythmMatchState({
    required this.targetNote,
    required this.sessionId,
    this.xp = 0,
    this.livesTotal = 3,
    this.livesRemaining = 3,
    this.roundIndex = 0,
    this.correctCount = 0,
    this.totalRounds = 10,
    this.feedback = RoundFeedback.none,
    this.isSessionOver = false,
    this.completion,
  });

  final String targetNote;
  final int sessionId;
  final int xp;
  final int livesTotal;
  final int livesRemaining;

  /// Jumlah ronde yang SUDAH diselesaikan (kena maupun meleset/miss).
  final int roundIndex;

  /// Jumlah ronde yang kena (nada benar DAN tepat waktu) — dipisah dari
  /// roundIndex, sama seperti mode lain, supaya akurasi sesi tidak
  /// perlu ditebak dari xp.
  final int correctCount;
  final int totalRounds;
  final RoundFeedback feedback;
  final bool isSessionOver;

  /// Hasil ProgressionRepository.completeSession() — null selama sesi
  /// masih berjalan ATAU sudah berakhir tapi orkestrasi progression
  /// belum selesai diawait. Pola sama seperti Note Recognition &
  /// Interval Training.
  final SessionCompletionResult? completion;

  /// 0.0 - 1.0, dikonsumsi langsung oleh ExplorerGameplayScreen.progress.
  double get progress =>
      totalRounds == 0 ? 0.0 : (roundIndex / totalRounds).clamp(0.0, 1.0);

  /// 0.0 - 1.0, dikonsumsi SessionResultScreen (ring akurasi).
  double get accuracy =>
      roundIndex == 0 ? 0.0 : (correctCount / roundIndex).clamp(0.0, 1.0);

  /// Menang = sesi berakhir karena semua ronde selesai dengan hearts
  /// masih tersisa (bukan karena hearts habis).
  bool get isWin => livesRemaining > 0;

  RhythmMatchState copyWith({
    String? targetNote,
    int? sessionId,
    int? xp,
    int? livesTotal,
    int? livesRemaining,
    int? roundIndex,
    int? correctCount,
    int? totalRounds,
    RoundFeedback? feedback,
    bool? isSessionOver,
    SessionCompletionResult? completion,
  }) {
    return RhythmMatchState(
      targetNote: targetNote ?? this.targetNote,
      sessionId: sessionId ?? this.sessionId,
      xp: xp ?? this.xp,
      livesTotal: livesTotal ?? this.livesTotal,
      livesRemaining: livesRemaining ?? this.livesRemaining,
      roundIndex: roundIndex ?? this.roundIndex,
      correctCount: correctCount ?? this.correctCount,
      totalRounds: totalRounds ?? this.totalRounds,
      feedback: feedback ?? this.feedback,
      isSessionOver: isSessionOver ?? this.isSessionOver,
      completion: completion ?? this.completion,
    );
  }
}