// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs_dao.dart';

// ignore_for_file: type=lint
mixin _$JobDaoMixin on DatabaseAccessor<AppDatabase> {
  $JobsDbModelTable get jobsDbModel => attachedDatabase.jobsDbModel;
  JobDaoManager get managers => JobDaoManager(this);
}

class JobDaoManager {
  final _$JobDaoMixin _db;
  JobDaoManager(this._db);
  $$JobsDbModelTableTableManager get jobsDbModel =>
      $$JobsDbModelTableTableManager(_db.attachedDatabase, _db.jobsDbModel);
}
