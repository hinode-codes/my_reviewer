import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_groups_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_transcription_dao.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/models/scanned_document_groups_db_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/models/scanned_document_transcriptions_db_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/models/scanned_documents_db_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/views/scanned_document_group_count.dart';
import 'package:my_reviewer/src/shared/db/dao/jobs_dao.dart';
import 'package:my_reviewer/src/shared/db/models/jobs_db_model.dart';
import 'package:my_reviewer/src/shared/utils/strings.dart';
import 'package:path_provider/path_provider.dart';

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
    return driftDatabase(
      name: 'my_reviewer',
      native: DriftNativeOptions(
        databaseDirectory: getApplicationDocumentsDirectory,
        shareAcrossIsolates: true,
        setup: (database) {
          database.execute('PRAGMA journal_mode = WAL;');
          database.execute('PRAGMA busy_timeout = 5000;');
          database.execute('PRAGMA foreign_keys = ON;');
        },
      ),
    );
  }
}
