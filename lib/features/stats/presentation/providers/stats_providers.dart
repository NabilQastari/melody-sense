import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/domain/entities/progression_entities.dart';
import 'package:melody_sense/core/providers/database_providers.dart';

/// ── Note Accuracy ──────────────────────────────────────────────
/// Akurasi per nada (B3–C5), lintas semua sesi. Dipakai untuk bar
/// chart di Stats screen.
final noteAccuracyProvider =
    FutureProvider<List<NoteAccuracyStat>>((ref) async {
  final repo = ref.watch(practiceRepositoryProvider);
  return repo.getAccuracyPerNote();
});

/// ── Recent Sessions ────────────────────────────────────────────
/// Semua sesi yang pernah dimainkan, terbaru di atas. Stream supaya
/// kalau user baru selesai latihan lalu buka Stats, list langsung
/// ter-update tanpa perlu refresh manual.
final recentSessionsProvider = StreamProvider<List<PracticeSession>>((ref) {
  final repo = ref.watch(practiceRepositoryProvider);
  return repo.watchAllSessions();
});

/// ── Achievements / Badges ──────────────────────────────────────
final achievementsProvider = StreamProvider<List<AchievementEntry>>((ref) {
  final repo = ref.watch(progressionRepositoryProvider);
  return repo.watchAchievements();
});

/// ── Level Info ─────────────────────────────────────────────────
final levelInfoProvider = StreamProvider<LevelInfo>((ref) {
  final repo = ref.watch(progressionRepositoryProvider);
  return repo.watchLevelInfo();
});

/// ── Daily Streak ───────────────────────────────────────────────
final streakProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(progressionRepositoryProvider);
  return repo.getCurrentStreakDays();
});

/// ── Top Personal Best ──────────────────────────────────────────
final topPersonalBestProvider = StreamProvider<PersonalBestEntry?>((ref) {
  final repo = ref.watch(progressionRepositoryProvider);
  return repo.watchTopPersonalBest();
});
