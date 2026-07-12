import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/personal_bests_table.dart';

part 'personal_best_dao.g.dart';

@DriftAccessor(tables: [PersonalBests])
class PersonalBestDao extends DatabaseAccessor<AppDatabase>
    with _$PersonalBestDaoMixin {
  PersonalBestDao(super.db);

  Future<PersonalBest?> getBest(String mode) {
    return (select(personalBests)..where((p) => p.mode.equals(mode)))
        .getSingleOrNull();
  }

  Stream<PersonalBest?> watchBest(String mode) {
    return (select(personalBests)..where((p) => p.mode.equals(mode)))
        .watchSingleOrNull();
  }

  /// Hanya menimpa record kalau skor baru lebih tinggi dari yang tersimpan.
  /// Mengembalikan true kalau berhasil jadi rekor baru.
  Future<bool> submitScore({required String mode, required int score}) async {
    final current = await getBest(mode);
    if (current != null && current.bestScore >= score) {
      return false;
    }
    await into(personalBests).insertOnConflictUpdate(
      PersonalBestsCompanion.insert(
        mode: mode,
        bestScore: score,
        achievedAt: Value(DateTime.now()),
      ),
    );
    return true;
  }
}
