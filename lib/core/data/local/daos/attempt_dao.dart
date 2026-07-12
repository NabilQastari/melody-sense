import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/attempts_table.dart';

part 'attempt_dao.g.dart';

@DriftAccessor(tables: [Attempts])
class AttemptDao extends DatabaseAccessor<AppDatabase> with _$AttemptDaoMixin {
  AttemptDao(super.db);

  /// Dipanggil tiap kali pemain menekan satu nada (benar atau salah).
  Future<int> logAttempt({
    required int sessionId,
    required String note,
    required bool isCorrect,
    required int responseTimeMs,
  }) {
    return into(attempts).insert(
      AttemptsCompanion.insert(
        sessionId: sessionId,
        note: note,
        isCorrect: isCorrect,
        responseTimeMs: responseTimeMs,
      ),
    );
  }

  Future<List<Attempt>> getAttemptsBySession(int sessionId) {
    return (select(attempts)..where((a) => a.sessionId.equals(sessionId)))
        .get();
  }

  /// Dipakai untuk grafik "akurasi per nada": berapa % benar untuk tiap nada,
  /// digabung lintas semua sesi.
  Future<List<NoteAccuracy>> getAccuracyPerNote() async {
    final correctCount = attempts.isCorrect.count(
      filter: attempts.isCorrect.equals(true),
    );
    final totalCount = attempts.id.count();

    final query = selectOnly(attempts)
      ..addColumns([attempts.note, correctCount, totalCount])
      ..groupBy([attempts.note]);

    final rows = await query.get();
    return rows.map((row) {
      final total = row.read(totalCount) ?? 0;
      final correct = row.read(correctCount) ?? 0;
      return NoteAccuracy(
        note: row.read(attempts.note)!,
        totalAttempts: total,
        correctAttempts: correct,
        accuracy: total == 0 ? 0 : correct / total,
      );
    }).toList();
  }
}

/// DTO hasil agregasi, bukan tabel — dipakai layer statistik/grafik.
class NoteAccuracy {
  final String note;
  final int totalAttempts;
  final int correctAttempts;
  final double accuracy;

  NoteAccuracy({
    required this.note,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.accuracy,
  });
}
