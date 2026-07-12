import 'package:drift/drift.dart';

/// Satu baris = satu sesi latihan (misalnya satu putaran Note Recognition).
/// xp_earned & score diisi saat sesi selesai (endedAt terisi).
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Disimpan sebagai string: 'note_recognition', 'interval_training',
  /// 'melody_echo', 'rhythm_match'. Mapping ke enum dilakukan di domain layer.
  TextColumn get mode => text()();

  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();

  /// Null selama sesi masih berjalan.
  DateTimeColumn get endedAt => dateTime().nullable()();

  IntColumn get xpEarned => integer().withDefault(const Constant(0))();

  IntColumn get score => integer().withDefault(const Constant(0))();
}
