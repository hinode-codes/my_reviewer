import 'package:drift/drift.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/models/scanned_document_groups_db_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/db/models/scanned_documents_db_model.dart';

abstract class ScannedDocumentGroupCount extends View {
  ScannedDocumentGroupsDbModel get groups;
  ScannedDocumentsDbModel get scannedDocuments;

  Expression<int> get docCount => scannedDocuments.id.count();

  @override
  Query as() => select([groups.id, docCount]).from(groups).join([
    leftOuterJoin(
      scannedDocuments,
      scannedDocuments.groupId.equalsExp(groups.id),
    ),
  ])..groupBy([groups.id]);
}
