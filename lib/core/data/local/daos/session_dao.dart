import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sessions_table.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [Sessions])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  /// Dipanggil saat sesi latihan dimulai. endedAt masih null.
  Future<int> startSession({required String mode}) {
    return into(sessions).insert(
      SessionsCompanion.insert(mode: mode),
    );
  }

  /// Dipanggil saat sesi selesai, mengisi xpEarned & score.
  Future<void> finishSession({
    required int sessionId,
    required int xpEarned,
    required int score,
  }) {
    return (update(sessions)..where((s) => s.id.equals(sessionId))).write(
      SessionsCompanion(
        endedAt: Value(DateTime.now()),
        xpEarned: Value(xpEarned),
        score: Value(score),
      ),
    );
  }

  Future<List<Session>> getSessionsByMode(String mode) {
    return (select(sessions)
          ..where((s) => s.mode.equals(mode))
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
        .get();
  }

  Stream<List<Session>> watchAllSessions() {
    return (select(sessions)
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
        .watch();
  }

  /// XP total dihitung on-the-fly dari SUM(xp_earned), sesuai keputusan
  /// Sesi 1.
  Stream<int> watchTotalXp() {
    final xpSum = sessions.xpEarned.sum();
    final query = selectOnly(sessions)..addColumns([xpSum]);
    return query.watchSingle().map((row) => row.read(xpSum) ?? 0);
  }

  Future<int> getTotalXp() async {
    final xpSum = sessions.xpEarned.sum();
    final query = selectOnly(sessions)..addColumns([xpSum]);
    final row = await query.getSingle();
    return row.read(xpSum) ?? 0;
  }

  /// Tanggal (tanpa komponen jam) dari sesi-sesi yang SUDAH selesai,
  /// dipakai ProgressionRepository untuk menghitung streak harian.
  /// Dedupe per-hari dilakukan di Dart, bukan lewat SQL date(), supaya
  /// tidak bergantung ke fungsi tanggal spesifik SQLite.
  Future<List<DateTime>> getDistinctSessionDays() async {
    final rows =
        await (select(sessions)..where((s) => sessions.endedAt.isNotNull()))
            .get();
    return rows
        .map((r) => r.endedAt!)
        .map((dt) => DateTime(dt.year, dt.month, dt.day))
        .toSet()
        .toList();
  }
}
