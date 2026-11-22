import 'package:drift/drift.dart';
import 'package:my_reviewer/src/shared/db/models/date_metadata_mixin.dart';
import 'package:my_reviewer/src/shared/db/models/ext_metadata_mixin.dart';
import 'package:my_reviewer/src/shared/db/models/id_metadata_mixin.dart';
import 'package:my_reviewer/src/shared/db/models/name_metadata_mixin.dart';
import 'package:my_reviewer/src/shared/db/models/path_metadata_mixin.dart';

import 'scanned_document_groups_db_model.dart';

class ScannedDocumentsDbModel extends Table
    with
        DateMetadataMixin,
        PathMetadataMixin,
        IdMetadataMixin,
        NameMetadataMixin,
        ExtMetadataMixin {
  TextColumn get groupId => text().references(
    ScannedDocumentGroupsDbModel,
    #id,
    onDelete: KeyAction.cascade,
  )();
}
