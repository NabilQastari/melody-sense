import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/app_database.dart';
import '../data/repositories/practice_repository_impl.dart';
import '../data/repositories/progression_repository_impl.dart';
import '../domain/repositories/practice_repository.dart';
import '../domain/repositories/progression_repository.dart';

/// Satu instance AppDatabase untuk seluruh aplikasi (singleton di level provider).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final practiceRepositoryProvider = Provider<PracticeRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PracticeRepositoryImpl(db);
});

final progressionRepositoryProvider = Provider<ProgressionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProgressionRepositoryImpl(db);
});
