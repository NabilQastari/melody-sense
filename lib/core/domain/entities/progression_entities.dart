import 'practice_entities.dart';

/// XP dibutuhkan per level, linear (level 1 = 0-99 XP, level 2 = 100-199
/// XP, dst). Keputusan Sesi 5: formula linear sederhana, bukan bertingkat.
const kXpPerLevel = 100;

class PersonalBestEntry {
  final TrainingMode mode;
  final int bestScore;
  final DateTime achievedAt;

  const PersonalBestEntry({
    required this.mode,
    required this.bestScore,
    required this.achievedAt,
  });
}

class AchievementEntry {
  final int id;
  final String title;
  final bool unlocked;
  final int progressCurrent;
  final int progressTarget;
  final DateTime? unlockedAt;

  const AchievementEntry({
    required this.id,
    required this.title,
    required this.unlocked,
    required this.progressCurrent,
    required this.progressTarget,
    this.unlockedAt,
  });

  double get progressRatio =>
      progressTarget == 0 ? 0 : progressCurrent / progressTarget;
}

/// Level pemain, diturunkan on-the-fly dari total XP (prinsip sama seperti
/// totalXp: dihitung, bukan disimpan sebagai kolom terpisah).
/// Formula Sesi 5: linear, 100 XP per level (level 1 dimulai dari 0 XP).
class LevelInfo {
  final int level;
  final int totalXp;

  /// XP yang sudah terkumpul di level saat ini (0 - xpForNextLevel).
  final int xpIntoLevel;

  /// Selalu kXpPerLevel untuk formula linear saat ini — dibiarkan sebagai
  /// field (bukan konstanta langsung dipakai di UI) supaya gampang diganti
  /// ke formula bertingkat nanti tanpa mengubah pemanggil.
  final int xpForNextLevel;

  const LevelInfo({
    required this.level,
    required this.totalXp,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  /// 0.0 - 1.0, progress menuju level berikutnya.
  double get progress =>
      xpForNextLevel == 0 ? 0.0 : xpIntoLevel / xpForNextLevel;

  factory LevelInfo.fromTotalXp(int totalXp) {
    final level = (totalXp ~/ kXpPerLevel) + 1;
    final xpIntoLevel = totalXp % kXpPerLevel;
    return LevelInfo(
      level: level,
      totalXp: totalXp,
      xpIntoLevel: xpIntoLevel,
      xpForNextLevel: kXpPerLevel,
    );
  }
}

/// Hasil orkestrasi ProgressionRepository.completeSession() — dipanggil
/// controller tiap kali sebuah sesi latihan berakhir. Menggabungkan semua
/// efek samping progression (personal best, level, streak, achievement)
/// jadi satu objek supaya UI (SessionResultScreen) tidak perlu tahu detail
/// masing-masing sumbernya.
class SessionCompletionResult {
  final bool isNewPersonalBest;
  final bool leveledUp;
  final LevelInfo levelInfo;
  final int streakDays;
  final List<AchievementEntry> newlyUnlockedAchievements;

  const SessionCompletionResult({
    required this.isNewPersonalBest,
    required this.leveledUp,
    required this.levelInfo,
    required this.streakDays,
    this.newlyUnlockedAchievements = const [],
  });
}
