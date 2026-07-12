import 'practice_entities.dart';

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
