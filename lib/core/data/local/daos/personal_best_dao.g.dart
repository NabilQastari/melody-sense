// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_best_dao.dart';

// ignore_for_file: type=lint
mixin _$PersonalBestDaoMixin on DatabaseAccessor<AppDatabase> {
  $PersonalBestsTable get personalBests => attachedDatabase.personalBests;
  PersonalBestDaoManager get managers => PersonalBestDaoManager(this);
}

class PersonalBestDaoManager {
  final _$PersonalBestDaoMixin _db;
  PersonalBestDaoManager(this._db);
  $$PersonalBestsTableTableManager get personalBests =>
      $$PersonalBestsTableTableManager(_db.attachedDatabase, _db.personalBests);
}
