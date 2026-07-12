import '../../domain/entities/practice_entities.dart';
import '../../domain/entities/progression_entities.dart';
import '../../domain/repositories/progression_repository.dart';
import '../local/app_database.dart';

class ProgressionRepositoryImpl implements ProgressionRepository {
  final AppDatabase _db;

  ProgressionRepositoryImpl(this._db);

  @override
  Future<int> getTotalXp() => _db.sessionDao.getTotalXp();

  @override
  Stream<int> watchTotalXp() => _db.sessionDao.watchTotalXp();

  @override
  Future<PersonalBestEntry?> getPersonalBest(TrainingMode mode) async {
    final row = await _db.personalBestDao.getBest(mode.storageKey);
    return row == null ? null : _mapPersonalBest(row);
  }

  @override
  Stream<PersonalBestEntry?> watchPersonalBest(TrainingMode mode) {
    return _db.personalBestDao
        .watchBest(mode.storageKey)
        .map((row) => row == null ? null : _mapPersonalBest(row));
  }

  @override
  Future<bool> submitScore({
    required TrainingMode mode,
    required int score,
  }) {
    return _db.personalBestDao.submitScore(
      mode: mode.storageKey,
      score: score,
    );
  }

  @override
  Stream<List<AchievementEntry>> watchAchievements() {
    return _db.achievementDao.watchAll().map(
          (rows) => rows.map(_mapAchievement).toList(),
        );
  }

  @override
  Future<void> incrementAchievementProgress(int achievementId, int amount) {
    return _db.achievementDao.incrementProgress(achievementId, amount);
  }

  PersonalBestEntry _mapPersonalBest(PersonalBest row) {
    return PersonalBestEntry(
      mode: TrainingMode.fromStorageKey(row.mode),
      bestScore: row.bestScore,
      achievedAt: row.achievedAt,
    );
  }

  AchievementEntry _mapAchievement(Achievement row) {
    return AchievementEntry(
      id: row.id,
      title: row.title,
      unlocked: row.unlocked,
      progressCurrent: row.progressCurrent,
      progressTarget: row.progressTarget,
      unlockedAt: row.unlockedAt,
    );
  }
}
