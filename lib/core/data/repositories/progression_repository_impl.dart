import '../../domain/entities/achievement_definitions.dart';
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
  Future<LevelInfo> getLevelInfo() async {
    final totalXp = await getTotalXp();
    return LevelInfo.fromTotalXp(totalXp);
  }

  @override
  Stream<LevelInfo> watchLevelInfo() {
    return watchTotalXp().map(LevelInfo.fromTotalXp);
  }

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

  @override
  Future<void> seedDefaultAchievementsIfEmpty() {
    final companions = defaultAchievementDefinitions
        .map((d) => AchievementsCompanion.insert(
              title: d.title,
              progressTarget: d.progressTarget,
            ))
        .toList();
    return _db.achievementDao.seedIfEmpty(companions);
  }

  @override
  Future<int> getCurrentStreakDays() async {
    final days = await _db.sessionDao.getDistinctSessionDays();
    return _computeStreakDays(days);
  }

  @override
  Future<SessionCompletionResult> completeSession({
    required TrainingMode mode,
    required int score,
    required int xpEarnedThisSession,
    required int correctCount,
    required int totalRounds,
  }) async {
    final isNewPersonalBest = await submitScore(mode: mode, score: score);

    // getTotalXp() dipanggil SETELAH SessionDao.finishSession() (kontrak
    // di dokumentasi interface), jadi totalXpAfter sudah termasuk XP sesi
    // ini. totalXpBefore diturunkan dengan mengurangi xpEarnedThisSession
    // supaya level-up bisa dideteksi tanpa query tambahan.
    final totalXpAfter = await getTotalXp();
    final totalXpBefore = totalXpAfter - xpEarnedThisSession;
    final levelBefore = LevelInfo.fromTotalXp(totalXpBefore).level;
    final levelInfo = LevelInfo.fromTotalXp(totalXpAfter);
    final leveledUp = levelInfo.level > levelBefore;

    final streakDays = await getCurrentStreakDays();

    final newlyUnlocked = <AchievementEntry>[];

    Future<void> bumpByIncrement(String title, int amount) async {
      if (amount <= 0) return;
      final before = await _db.achievementDao.getByTitle(title);
      if (before == null || before.unlocked) return;
      await _db.achievementDao.incrementProgress(before.id, amount);
      final after = await _db.achievementDao.getByTitle(title);
      if (after != null && after.unlocked) {
        newlyUnlocked.add(_mapAchievement(after));
      }
    }

    Future<void> bumpBySet(String title, int newProgress) async {
      final before = await _db.achievementDao.getByTitle(title);
      if (before == null || before.unlocked) return;
      await _db.achievementDao.setProgress(before.id, newProgress);
      final after = await _db.achievementDao.getByTitle(title);
      if (after != null && after.unlocked) {
        newlyUnlocked.add(_mapAchievement(after));
      }
    }

    // Achievement akumulatif — nilainya cuma nambah seiring waktu.
    await bumpByIncrement(AchievementTitles.firstNotes, 1);
    await bumpByIncrement(AchievementTitles.dedicatedLearner, 1);
    await bumpByIncrement(AchievementTitles.noteMaster, correctCount);

    // Achievement berbasis kondisi sesi ini saja — di-set langsung ke
    // target begitu syaratnya terpenuhi (one-shot, bukan akumulasi).
    if (totalRounds > 0 && correctCount == totalRounds) {
      await bumpBySet(AchievementTitles.perfectRound, 1);
    }
    if (score >= 100) {
      await bumpBySet(AchievementTitles.centuryScorer, 1);
    }

    // Achievement berbasis streak — nilainya bisa naik-turun, jadi
    // di-set absolut ke streak saat ini (bukan increment).
    await bumpBySet(AchievementTitles.onFire, streakDays);

    return SessionCompletionResult(
      isNewPersonalBest: isNewPersonalBest,
      leveledUp: leveledUp,
      levelInfo: levelInfo,
      streakDays: streakDays,
      newlyUnlockedAchievements: newlyUnlocked,
    );
  }

  /// Menghitung streak harian (jumlah hari berturut-turut ada sesi yang
  /// selesai) dari daftar tanggal unik, terhitung mundur dari hari ini.
  /// Streak dianggap masih "hidup" kalau sesi terakhir terjadi hari ini
  /// atau kemarin (grace period 1 hari); lebih dari itu, streak putus (0).
  int _computeStreakDays(List<DateTime> days) {
    if (days.isEmpty) return 0;

    final sorted = days.toSet().toList()..sort((a, b) => b.compareTo(a));
    final today = _dateOnly(DateTime.now());
    final gapFromToday = today.difference(sorted.first).inDays;
    if (gapFromToday > 1) return 0;

    var streak = 1;
    for (var i = 0; i < sorted.length - 1; i++) {
      final diff = sorted[i].difference(sorted[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

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
