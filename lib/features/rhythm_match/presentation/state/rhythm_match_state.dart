import 'package:flutter/foundation.dart';

import 'package:melody_sense/core/domain/entities/practice_entities.dart'
    show RoundFeedback, PracticeSubmode;
import 'package:melody_sense/core/domain/entities/progression_entities.dart';

import '../../domain/entities/song_entity.dart';

@immutable
class RhythmMatchState {
  const RhythmMatchState({
    required this.selectedSong,
    required this.sessionId,
    this.submode = PracticeSubmode.practice,
    this.currentNoteIndex = 0,
    this.correctCount = 0,
    this.totalAttempts = 0,
    this.xp = 0,
    this.startedAt,
    this.completedMs,
    this.stars = 0,
    this.feedback = RoundFeedback.none,
    this.lastPressedNote,
    this.isSessionOver = false,
    this.completion,
  });

  final RhythmSong selectedSong;
  final int sessionId;
  final PracticeSubmode submode;

  /// Indeks nada aktif dalam melodi lagu (0 s/d `selectedSong.totalNotes - 1`).
  final int currentNoteIndex;

  /// Jumlah tuts yang ditekan BENAR sejauh ini.
  final int correctCount;

  /// Total penekanan tuts yang dilakukan user.
  final int totalAttempts;

  final int xp;
  final DateTime? startedAt;

  /// Waktu penyelesaian total lagu dalam milidetik (null selama lagu masih dimainkan).
  final int? completedMs;

  /// Jumlah bintang rekor (1-3 bintang ⭐⭐⭐).
  final int stars;

  final RoundFeedback feedback;
  final String? lastPressedNote;
  final bool isSessionOver;
  final SessionCompletionResult? completion;

  /// Nada yang HARUS ditekan user saat ini.
  String get targetNote =>
      currentNoteIndex < selectedSong.notes.length
          ? selectedSong.notes[currentNoteIndex]
          : selectedSong.notes.last;

  /// Progres lagu (0.0 - 1.0).
  double get progress => selectedSong.totalNotes == 0
      ? 0.0
      : (currentNoteIndex / selectedSong.totalNotes).clamp(0.0, 1.0);

  /// Akurasi nada (0.0 - 1.0).
  double get accuracy => totalAttempts == 0
      ? 1.0
      : (correctCount / totalAttempts).clamp(0.0, 1.0);

  /// Waktu berlalu dalam milidetik sejauh ini.
  int get currentElapsedMs {
    if (completedMs != null) return completedMs!;
    if (startedAt == null) return 0;
    return DateTime.now().difference(startedAt!).inMilliseconds;
  }

  RhythmMatchState copyWith({
    RhythmSong? selectedSong,
    int? sessionId,
    PracticeSubmode? submode,
    int? currentNoteIndex,
    int? correctCount,
    int? totalAttempts,
    int? xp,
    DateTime? startedAt,
    int? completedMs,
    int? stars,
    RoundFeedback? feedback,
    String? lastPressedNote,
    bool? isSessionOver,
    SessionCompletionResult? completion,
  }) {
    return RhythmMatchState(
      selectedSong: selectedSong ?? this.selectedSong,
      sessionId: sessionId ?? this.sessionId,
      submode: submode ?? this.submode,
      currentNoteIndex: currentNoteIndex ?? this.currentNoteIndex,
      correctCount: correctCount ?? this.correctCount,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      xp: xp ?? this.xp,
      startedAt: startedAt ?? this.startedAt,
      completedMs: completedMs ?? this.completedMs,
      stars: stars ?? this.stars,
      feedback: feedback ?? this.feedback,
      lastPressedNote: lastPressedNote ?? this.lastPressedNote,
      isSessionOver: isSessionOver ?? this.isSessionOver,
      completion: completion ?? this.completion,
    );
  }
}