import 'package:flutter/foundation.dart';

import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/domain/entities/progression_entities.dart';

@immutable
class NoteRecognitionState {
  const NoteRecognitionState({
    required this.targetNote,
    required this.sessionId,
    required this.mysteryRoundIndex,
    this.lastPressedNote,
    this.isPlaying = false,
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
  final int mysteryRoundIndex;
  final String? lastPressedNote;
  final bool isPlaying;
  final int xp;
  final int livesTotal;
  final int livesRemaining;

  /// Jumlah ronde yang SUDAH diselesaikan (benar maupun salah).
  final int roundIndex;

  /// Jumlah jawaban BENAR saja — dipisah dari [roundIndex] supaya
  /// akurasi sesi (dipakai SessionResultScreen) tidak perlu ditebak
  /// dari xp.
  final int correctCount;
  final int totalRounds;
  final RoundFeedback feedback;
  final bool isSessionOver;

  /// Hasil ProgressionRepository.completeSession() (Sesi 5) — null
  /// selama sesi masih berjalan ATAU sudah berakhir tapi orkestrasi
  /// progression (personal best/level/streak/achievement) belum selesai
  /// diawait. NoteRecognitionScreen menunggu field ini terisi sebelum
  /// pindah ke SessionResultScreen, supaya streakDays/leveledUp yang
  /// ditampilkan bukan data basi.
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

  NoteRecognitionState copyWith({
    String? targetNote,
    int? sessionId,
    int? mysteryRoundIndex,
    String? lastPressedNote,
    bool? isPlaying,
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
    return NoteRecognitionState(
      targetNote: targetNote ?? this.targetNote,
      sessionId: sessionId ?? this.sessionId,
      mysteryRoundIndex: mysteryRoundIndex ?? this.mysteryRoundIndex,
      lastPressedNote: lastPressedNote ?? this.lastPressedNote,
      isPlaying: isPlaying ?? this.isPlaying,
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

