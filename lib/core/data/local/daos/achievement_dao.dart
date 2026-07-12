import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/achievements_table.dart';

part 'achievement_dao.g.dart';

@DriftAccessor(tables: [Achievements])
class AchievementDao extends DatabaseAccessor<AppDatabase>
    with _$AchievementDaoMixin {
  AchievementDao(super.db);

  Stream<List<Achievement>> watchAll() {
    return select(achievements).watch();
  }

  Future<List<Achievement>> getAll() => select(achievements).get();

  /// Dipanggil sekali di awal (mis. saat app pertama kali dibuka) untuk
  /// mengisi daftar achievement bawaan kalau tabel masih kosong.
  /// Daftar konkretnya masih perlu difinalisasi tim (belum dibahas di Sesi 1/2).
  Future<void> seedIfEmpty(List<AchievementsCompanion> defaults) async {
    final existing = await getAll();
    if (existing.isNotEmpty) return;
    await batch((b) => b.insertAll(achievements, defaults));
  }

  /// Menambah progress; otomatis unlock kalau progressCurrent mencapai target.
  Future<void> incrementProgress(int id, int amount) async {
    final achievement =
        await (select(achievements)..where((a) => a.id.equals(id)))
            .getSingle();
    if (achievement.unlocked) return;

    final newProgress =
        (achievement.progressCurrent + amount).clamp(0, achievement.progressTarget);
    final shouldUnlock = newProgress >= achievement.progressTarget;

    await (update(achievements)..where((a) => a.id.equals(id))).write(
      AchievementsCompanion(
        progressCurrent: Value(newProgress),
        unlocked: Value(shouldUnlock),
        unlockedAt: shouldUnlock ? Value(DateTime.now()) : const Value.absent(),
      ),
    );
  }
}
