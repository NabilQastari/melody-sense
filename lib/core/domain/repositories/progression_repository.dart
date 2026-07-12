import '../entities/practice_entities.dart';
import '../entities/progression_entities.dart';

abstract class ProgressionRepository {
  /// XP total dihitung on-the-fly dari SUM(xp_earned) di tabel sessions,
  /// sesuai keputusan Sesi 1 (bukan disimpan sebagai kolom terpisah).
  Future<int> getTotalXp();
  Stream<int> watchTotalXp();

  Future<PersonalBestEntry?> getPersonalBest(TrainingMode mode);
  Stream<PersonalBestEntry?> watchPersonalBest(TrainingMode mode);

  /// Mengembalikan true kalau skor ini jadi rekor baru untuk mode tsb.
  Future<bool> submitScore({required TrainingMode mode, required int score});

  Stream<List<AchievementEntry>> watchAchievements();
  Future<void> incrementAchievementProgress(int achievementId, int amount);
}
