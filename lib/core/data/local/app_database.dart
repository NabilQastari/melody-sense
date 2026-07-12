import 'package:drift/drift.dart';

import 'connection/connection.dart' as impl;
import 'daos/achievement_dao.dart';
import 'daos/attempt_dao.dart';
import 'daos/personal_best_dao.dart';
import 'daos/session_dao.dart';
import 'tables/achievements_table.dart';
import 'tables/attempts_table.dart';
import 'tables/personal_bests_table.dart';
import 'tables/sessions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Sessions, Attempts, PersonalBests, Achievements],
  daos: [SessionDao, AttemptDao, PersonalBestDao, AchievementDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.connect());

  // Untuk unit test: bisa inject in-memory QueryExecutor sendiri.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
