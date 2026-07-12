import 'package:drift/drift.dart';

/// Satu baris per mode latihan (mode jadi primary key, bukan auto id),
/// karena tiap mode cuma punya satu skor terbaik yang di-overwrite.
class PersonalBests extends Table {
  TextColumn get mode => text()();

  IntColumn get bestScore => integer()();

  DateTimeColumn get achievedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {mode};
}
