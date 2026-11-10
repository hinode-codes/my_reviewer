import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:my_reviewer/src/db/dao/docs_dao.dart';
import 'package:my_reviewer/src/db/models/docs_models.dart';
import 'package:my_reviewer/src/db/views/docs_views.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:my_reviewer/src/utils/string.dart';

part "app_database.g.dart";

@DriftDatabase(
  tables: [ScannedDocumentsGroups, ScannedDocuments],
  views: [ScannedDocumentsView, ScannedGroupDocCount],
  daos: [ScannedDocumentsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, "my_reviewer.sqlite"));
      final cacheFolder = (await getTemporaryDirectory()).path;

      sqlite3.tempDirectory = cacheFolder;

      return NativeDatabase.createInBackground(file);
    });
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement("PRAGMA foreign_keys = ON");
      },
    );
  }
}
