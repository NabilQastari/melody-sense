import '../entities/practice_entities.dart';
import '../entities/progression_entities.dart';

abstract class ProgressionRepository {
  /// XP total dihitung on-the-fly dari SUM(xp_earned) di tabel sessions,
  /// sesuai keputusan Sesi 1 (bukan disimpan sebagai kolom terpisah).
  Future<int> getTotalXp();
  Stream<int> watchTotalXp();

  /// Level pemain, diturunkan dari getTotalXp()/watchTotalXp() (linear,
  /// 100 XP per level — lihat LevelInfo).
  Future<LevelInfo> getLevelInfo();
  Stream<LevelInfo> watchLevelInfo();

  Future<PersonalBestEntry?> getPersonalBest(TrainingMode mode);
  Stream<PersonalBestEntry?> watchPersonalBest(TrainingMode mode);

  /// Mengembalikan true kalau skor ini jadi rekor baru untuk mode tsb.
  Future<bool> submitScore({required TrainingMode mode, required int score});

  Stream<List<AchievementEntry>> watchAchievements();
  Future<void> incrementAchievementProgress(int achievementId, int amount);

  /// Mengisi daftar achievement bawaan (lihat achievement_definitions.dart)
  /// kalau tabel achievements masih kosong. Aman dipanggil berkali-kali —
  /// no-op kalau sudah pernah ter-seed.
  Future<void> seedDefaultAchievementsIfEmpty();

  /// Jumlah hari berturut-turut pemain menyelesaikan minimal satu sesi,
  /// dihitung mundur dari hari ini (grace period 1 hari — streak masih
  /// dianggap hidup kalau sesi terakhir kemarin, bukan hari ini).
  Future<int> getCurrentStreakDays();

  /// Satu pintu orkestrasi yang dipanggil controller tiap sebuah sesi
  /// latihan berakhir: submit personal best, hitung level-up, hitung
  /// streak, dan update progress achievement — hasilnya digabung jadi
  /// satu [SessionCompletionResult] untuk dikonsumsi UI (mis.
  /// SessionResultScreen). Dipanggil SETELAH SessionDao.finishSession()
  /// supaya getTotalXp() sudah mencakup XP sesi ini.
  Future<SessionCompletionResult> completeSession({
    required TrainingMode mode,
    required int score,
    required int xpEarnedThisSession,
    required int correctCount,
    required int totalRounds,
  });
}
