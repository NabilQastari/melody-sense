import '../../domain/entities/practice_entities.dart';
import '../../domain/repositories/practice_repository.dart';
import '../local/app_database.dart';
import '../local/daos/attempt_dao.dart' show NoteAccuracy;

class PracticeRepositoryImpl implements PracticeRepository {
  final AppDatabase _db;

  PracticeRepositoryImpl(this._db);

  @override
  Future<int> startSession(TrainingMode mode) {
    return _db.sessionDao.startSession(mode: mode.storageKey);
  }

  @override
  Future<void> finishSession({
    required int sessionId,
    required int xpEarned,
    required int score,
  }) {
    return _db.sessionDao.finishSession(
      sessionId: sessionId,
      xpEarned: xpEarned,
      score: score,
    );
  }

  @override
  Future<void> logAttempt({
    required int sessionId,
    required String note,
    required bool isCorrect,
    required int responseTimeMs,
  }) {
    return _db.attemptDao.logAttempt(
      sessionId: sessionId,
      note: note,
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
    );
  }

  @override
  Future<List<PracticeSession>> getSessionsByMode(TrainingMode mode) async {
    final rows = await _db.sessionDao.getSessionsByMode(mode.storageKey);
    return rows.map(_mapSession).toList();
  }

  @override
  Stream<List<PracticeSession>> watchAllSessions() {
    return _db.sessionDao.watchAllSessions().map(
          (rows) => rows.map(_mapSession).toList(),
        );
  }

  @override
  Future<List<NoteAccuracyStat>> getAccuracyPerNote() async {
    final rows = await _db.attemptDao.getAccuracyPerNote();
    return rows.map(_mapAccuracy).toList();
  }

  PracticeSession _mapSession(Session row) {
    return PracticeSession(
      id: row.id,
      mode: TrainingMode.fromStorageKey(row.mode),
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      xpEarned: row.xpEarned,
      score: row.score,
    );
  }

  NoteAccuracyStat _mapAccuracy(NoteAccuracy row) {
    return NoteAccuracyStat(
      note: row.note,
      totalAttempts: row.totalAttempts,
      correctAttempts: row.correctAttempts,
      accuracy: row.accuracy,
    );
  }
}
