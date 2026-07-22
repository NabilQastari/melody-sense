import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/audio/audio_service.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/domain/repositories/practice_repository.dart';
import 'package:melody_sense/core/domain/repositories/progression_repository.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/database_providers.dart';

import '../../domain/entities/song_entity.dart';
import '../state/rhythm_match_state.dart';

@immutable
class RhythmMatchArgs {
  const RhythmMatchArgs({
    required this.song,
    required this.submode,
  });

  final RhythmSong song;
  final PracticeSubmode submode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RhythmMatchArgs &&
          runtimeType == other.runtimeType &&
          other.song.id == song.id &&
          other.submode == submode;

  @override
  int get hashCode => Object.hash(song.id, submode);
}

/// Controller untuk Rhythm Match berbasis permainan lagu.
class RhythmMatchController extends StateNotifier<RhythmMatchState?> {
  RhythmMatchController(this._ref, this._args) : super(null) {
    _start();
  }

  final Ref _ref;
  final RhythmMatchArgs _args;

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
      selectedSong: _args.song,
      sessionId: sessionId,
      submode: _args.submode,
      startedAt: DateTime.now(),
    );
  }

  /// Memutar nada target saat ini (preview / Auto Play).
  void playCurrentTarget() {
    final current = state;
    if (current == null || current.isSessionOver) return;
    _audio.playNote(current.targetNote);
  }

  /// Dipanggil setiap kali pengguna menekan tuts piano.
  Future<void> submitNote(String note) async {
    final current = state;
    if (current == null || current.isSessionOver) return;

    _audio.playNote(note);

    final String target = current.targetNote;
    final bool isCorrect = note == target;
    final now = DateTime.now();
    final responseTimeMs = current.startedAt != null
        ? now.difference(current.startedAt!).inMilliseconds
        : 0;

    await _practiceRepo.logAttempt(
      sessionId: current.sessionId,
      note: note,
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
    );

    final nextAttempts = current.totalAttempts + 1;
    final nextCorrect = isCorrect ? current.correctCount + 1 : current.correctCount;
    final nextIndex = current.currentNoteIndex + 1;
    final bool songCompleted = nextIndex >= current.selectedSong.totalNotes;

    if (songCompleted) {
      final elapsedMs = now.difference(current.startedAt!).inMilliseconds;
      final double accuracy = nextCorrect / nextAttempts;

      int stars = 1;
      if (accuracy >= 0.90) {
        stars = 3;
      } else if (accuracy >= 0.70) {
        stars = 2;
      }

      final xpEarned = (20 + (accuracy * 30).round() + (stars * 10));

      state = current.copyWith(
        currentNoteIndex: nextIndex,
        totalAttempts: nextAttempts,
        correctCount: nextCorrect,
        lastPressedNote: note,
        feedback: isCorrect ? RoundFeedback.correct : RoundFeedback.wrong,
        completedMs: elapsedMs,
        stars: stars,
        xp: xpEarned,
        isSessionOver: true,
      );

      await _finishSession(xpEarned: xpEarned);
    } else {
      state = current.copyWith(
        currentNoteIndex: nextIndex,
        totalAttempts: nextAttempts,
        correctCount: nextCorrect,
        lastPressedNote: note,
        feedback: isCorrect ? RoundFeedback.correct : RoundFeedback.wrong,
      );
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
      totalRounds: current.selectedSong.totalNotes,
    );

    state = state?.copyWith(completion: completion);
  }
}

final rhythmMatchControllerProvider = StateNotifierProvider.autoDispose.family<
    RhythmMatchController, RhythmMatchState?, RhythmMatchArgs>(
  (ref, args) => RhythmMatchController(ref, args),
);