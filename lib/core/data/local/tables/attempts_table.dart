import 'package:drift/drift.dart';

import 'sessions_table.dart';

/// Satu baris = satu percobaan/tekan nada dalam sebuah sesi.
/// Ini yang jadi dasar grafik akurasi per nada & tren waktu respons.
class Attempts extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();

  /// Nama nada, mis. "C4", "D#5".
  TextColumn get note => text()();

  BoolColumn get isCorrect => boolean()();

  IntColumn get responseTimeMs => integer()();

  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}
