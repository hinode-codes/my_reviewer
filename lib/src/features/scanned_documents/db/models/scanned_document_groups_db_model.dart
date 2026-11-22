import 'package:drift/drift.dart';
import 'package:my_reviewer/src/shared/db/models/date_metadata_mixin.dart';
import 'package:my_reviewer/src/shared/db/models/id_metadata_mixin.dart';
import 'package:my_reviewer/src/shared/db/models/name_metadata_mixin.dart';
import 'package:my_reviewer/src/shared/db/models/path_metadata_mixin.dart';

class ScannedDocumentGroupsDbModel extends Table
    with
        DateMetadataMixin,
        IdMetadataMixin,
        PathMetadataMixin,
        NameMetadataMixin {}
