import 'package:flutter/foundation.dart';

import 'package:melody_sense/core/domain/entities/progression_entities.dart';

/// 9 nada yang tersedia, sesuai file audio di assets/audio/notes/
/// (Sesi 3): B3.mp3, C4.mp3, D4.mp3, E4.mp3, F4.mp3, G4.mp3, A4.mp3,
/// B4.mp3, C5.mp3.
const kAvailableNotes = [
  'B3',
  'C4',
  'D4',
  'E4',
  'F4',
  'G4',
  'A4',
  'B4',
  'C5',
];

/// Hasil ronde terakhir, dipakai UI kalau nanti mau menampilkan
/// feedback visual (mis. flash hijau/merah). Belum dipakai di
/// ExplorerGameplayScreen versi Sesi 3, disiapkan untuk sesi polish.
enum RoundFeedback { none, correct, wrong }

@immutable
class NoteRecognitionState {
  const NoteRecognitionState({
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
