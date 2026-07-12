import '../entities/practice_entities.dart';

/// Kontrak yang dipakai fitur-fitur latihan (note_recognition, interval_training,
/// melody_echo, rhythm_match) untuk mencatat sesi & percobaan.
/// Implementasinya (pakai Drift) ada di data layer.
abstract class PracticeRepository {
  Future<int> startSession(TrainingMode mode);

  Future<void> finishSession({
    required int sessionId,
    required int xpEarned,
    required int score,
  });

  Future<void> logAttempt({
    required int sessionId,
    required String note,
    required bool isCorrect,
    required int responseTimeMs,
  });

  Future<List<PracticeSession>> getSessionsByMode(TrainingMode mode);

  Stream<List<PracticeSession>> watchAllSessions();

  Future<List<NoteAccuracyStat>> getAccuracyPerNote();
}
