// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attempt_dao.dart';

// ignore_for_file: type=lint
mixin _$AttemptDaoMixin on DatabaseAccessor<AppDatabase> {
  $SessionsTable get sessions => attachedDatabase.sessions;
  $AttemptsTable get attempts => attachedDatabase.attempts;
  AttemptDaoManager get managers => AttemptDaoManager(this);
}

class AttemptDaoManager {
  final _$AttemptDaoMixin _db;
  AttemptDaoManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db.attachedDatabase, _db.sessions);
  $$AttemptsTableTableManager get attempts =>
      $$AttemptsTableTableManager(_db.attachedDatabase, _db.attempts);
}
