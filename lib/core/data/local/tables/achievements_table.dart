import 'package:drift/drift.dart';

/// Daftar achievement yang di-seed sekali di awal (lihat AchievementDao.seedIfEmpty),
/// lalu progress-nya diupdate seiring pemain main.
class Achievements extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  BoolColumn get unlocked => boolean().withDefault(const Constant(false))();

  IntColumn get progressCurrent => integer().withDefault(const Constant(0))();

  IntColumn get progressTarget => integer()();

  DateTimeColumn get unlockedAt => dateTime().nullable()();
}
