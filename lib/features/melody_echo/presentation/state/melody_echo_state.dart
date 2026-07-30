import 'package:flutter/foundation.dart';

import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/domain/entities/progression_entities.dart';

/// Fase gameplay Melody Echo.
enum MelodyEchoPhase {
  /// App sedang memainkan melodi target — user mendengarkan.
  listening,

  /// Giliran user menekan tuts untuk mengulangi melodi.
  playing,

  /// Feedback ditampilkan (benar/salah) sebelum pindah ronde.
  feedback,
}

@immutable
class MelodyEchoState {
  const MelodyEchoState({
    required this.melody,
    required this.sessionId,
    this.submode = PracticeSubmode.practice,
    this.userInputs = const [],
    this.xp = 0,
    this.livesTotal = 3,
    this.livesRemaining = 3,
    this.roundIndex = 0,
    this.correctCount = 0,
    this.totalRounds = 8,
    this.phase = MelodyEchoPhase.listening,
    this.feedback = RoundFeedback.none,
    this.isSessionOver = false,
    this.isPlaying = false,
    this.completion,
  });

  /// Urutan nada yang harus diulang user di ronde ini.
  final List<String> melody;

  final int sessionId;
  final PracticeSubmode submode;

  /// Nada-nada yang sudah ditekan user di ronde ini (dikumpulkan satu per satu).
  final List<String> userInputs;

  final int xp;
  final int? livesTotal;
  final int? livesRemaining;
  final int roundIndex;
  final int correctCount;
  final int totalRounds;
  final MelodyEchoPhase phase;
  final RoundFeedback feedback;
  final bool isSessionOver;

  /// True saat melodi sedang diputar (animasi playing di NotePromptCard).
  final bool isPlaying;

  final SessionCompletionResult? completion;

  // ── Getters ──

  /// 0.0 - 1.0, progress bar di ExplorerGameplayScreen.
  double get progress =>
      totalRounds == 0 ? 0.0 : (roundIndex / totalRounds).clamp(0.0, 1.0);

  /// 0.0 - 1.0, akurasi untuk SessionResultScreen.
  double get accuracy =>
      roundIndex == 0 ? 0.0 : (correctCount / roundIndex).clamp(0.0, 1.0);

  /// Menang = sesi berakhir karena semua ronde selesai dengan hearts tersisa.
  bool get isWin => livesRemaining == null || livesRemaining! > 0;

  /// Index nada berikutnya yang harus ditekan user (0-based).
  int get currentInputIndex => userInputs.length;

  /// Panjang melodi saat ini.
  int get melodyLength => melody.length;

  /// Nada target berikutnya yang harus ditekan user.
  String? get nextExpectedNote =>
      currentInputIndex < melody.length ? melody[currentInputIndex] : null;

  MelodyEchoState copyWith({
    List<String>? melody,
    int? sessionId,
    PracticeSubmode? submode,
    List<String>? userInputs,
    int? xp,
    int? livesTotal,
    int? livesRemaining,
    int? roundIndex,
    int? correctCount,
    int? totalRounds,
    MelodyEchoPhase? phase,
    RoundFeedback? feedback,
    bool? isSessionOver,
    bool? isPlaying,
    SessionCompletionResult? completion,
  }) {
    return MelodyEchoState(
      melody: melody ?? this.melody,
      sessionId: sessionId ?? this.sessionId,
      submode: submode ?? this.submode,
      userInputs: userInputs ?? this.userInputs,
      xp: xp ?? this.xp,
      livesTotal: livesTotal ?? this.livesTotal,
      livesRemaining: livesRemaining ?? this.livesRemaining,
      roundIndex: roundIndex ?? this.roundIndex,
      correctCount: correctCount ?? this.correctCount,
      totalRounds: totalRounds ?? this.totalRounds,
      phase: phase ?? this.phase,
      feedback: feedback ?? this.feedback,
      isSessionOver: isSessionOver ?? this.isSessionOver,
      isPlaying: isPlaying ?? this.isPlaying,
      completion: completion ?? this.completion,
    );
  }
}
