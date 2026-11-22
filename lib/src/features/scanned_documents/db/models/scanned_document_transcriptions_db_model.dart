import 'package:drift/drift.dart';
import 'package:my_reviewer/src/shared/db/models/date_metadata_mixin.dart';
import 'package:my_reviewer/src/shared/db/models/ext_metadata_mixin.dart';
import 'package:my_reviewer/src/shared/db/models/id_metadata_mixin.dart';
import 'package:my_reviewer/src/shared/db/models/path_metadata_mixin.dart';

import 'scanned_documents_db_model.dart';

class ScannedDocumentTranscriptionsDbModel extends Table
    with
        DateMetadataMixin,
        PathMetadataMixin,
        ExtMetadataMixin,
        IdMetadataMixin {
  TextColumn get docId => text().unique().references(
    ScannedDocumentsDbModel,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get timeMsToTranscribe =>
      integer().withDefault(const Constant(0))();
  IntColumn get timeMsToRead => integer().withDefault(const Constant(0))();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();
}
