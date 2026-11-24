import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_groups_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_transcription_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/models/scanned_document_groups_db_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/models/scanned_document_transcriptions_db_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/models/scanned_documents_db_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/views/scanned_document_group_count.dart';
import 'package:my_reviewer/src/shared/db/dao/jobs_dao.dart';
import 'package:my_reviewer/src/shared/db/models/jobs_db_model.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:my_reviewer/src/shared/utils/strings.dart';

part "app_database.g.dart";

@DriftDatabase(
  tables: [
    ScannedDocumentGroupsDbModel,
    ScannedDocumentsDbModel,
    ScannedDocumentTranscriptionsDbModel,
    JobsDbModel,
  ],
  daos: [
    ScannedDocumentGroupsDao,
    ScannedDocumentDao,
    ScannedDocumentTranscriptionDao,
    JobDao,
  ],
  views: [ScannedDocumentGroupCount],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, "my_reviewer.sqlite"));
      final cacheFolder = (await getApplicationCacheDirectory()).path;

      sqlite3.tempDirectory = cacheFolder;

      return NativeDatabase.createInBackground(file);
    });
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA journal_mode = WAL;');
        await customStatement('PRAGMA busy_timeout = 5000;');
        await customStatement("PRAGMA foreign_keys = ON");
      },
    );
  }
}
