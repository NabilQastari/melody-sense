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

  /// Dipakai ProgressionRepository untuk mencocokkan achievement lewat
  /// judul (lihat AchievementTitles di achievement_definitions.dart),
  /// karena tabel ini tidak punya kolom "key" terpisah — judul dipakai
  /// sebagai identitas logis.
  Future<Achievement?> getByTitle(String title) {
    return (select(achievements)..where((a) => a.title.equals(title)))
        .getSingleOrNull();
  }

  /// Dipanggil sekali di awal (mis. saat app pertama kali dibuka) untuk
  /// mengisi daftar achievement bawaan kalau tabel masih kosong.
  Future<void> seedIfEmpty(List<AchievementsCompanion> defaults) async {
    final existing = await getAll();
    if (existing.isNotEmpty) return;
    await batch((b) => b.insertAll(achievements, defaults));
  }

  /// Menambah progress; otomatis unlock kalau progressCurrent mencapai
  /// target. Cocok untuk achievement akumulatif (mis. total sesi
  /// dimainkan, total nada benar) yang nilainya hanya naik seiring waktu.
  Future<void> incrementProgress(int id, int amount) async {
    final achievement =
        await (select(achievements)..where((a) => a.id.equals(id)))
            .getSingle();
    if (achievement.unlocked) return;

    final newProgress = (achievement.progressCurrent + amount)
        .clamp(0, achievement.progressTarget);
    final shouldUnlock = newProgress >= achievement.progressTarget;

    await (update(achievements)..where((a) => a.id.equals(id))).write(
      AchievementsCompanion(
        progressCurrent: Value(newProgress),
        unlocked: Value(shouldUnlock),
        unlockedAt:
            shouldUnlock ? Value(DateTime.now()) : const Value.absent(),
      ),
    );
  }

  /// Menimpa progress dengan nilai absolut (bukan menambah). Cocok untuk
  /// achievement yang nilainya bisa naik-turun (mis. streak harian) atau
  /// yang dicek langsung dari kondisi sesi (mis. "skor >= 100 dalam satu
  /// sesi" cukup di-set 1x ke target begitu syaratnya terpenuhi).
  Future<void> setProgress(int id, int newProgress) async {
    final achievement =
        await (select(achievements)..where((a) => a.id.equals(id)))
            .getSingle();
    if (achievement.unlocked) return;

    final clamped = newProgress.clamp(0, achievement.progressTarget);
    final shouldUnlock = clamped >= achievement.progressTarget;

    await (update(achievements)..where((a) => a.id.equals(id))).write(
      AchievementsCompanion(
        progressCurrent: Value(clamped),
        unlocked: Value(shouldUnlock),
        unlockedAt:
            shouldUnlock ? Value(DateTime.now()) : const Value.absent(),
      ),
    );
  }
}
