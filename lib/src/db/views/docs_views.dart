import 'package:drift/drift.dart';
import 'package:my_reviewer/src/db/models/docs_models.dart';

abstract class ScannedDocumentsView extends View {
  ScannedDocumentsGroups get groups;
  ScannedDocuments get scannedDocuments;

  // Custom getters to ensure every selected field has a unique name
  Expression<String> get groupId => groups.id;
  Expression<String> get groupName => groups.name;
  Expression<String> get docId => scannedDocuments.id;
  Expression<String> get docName => scannedDocuments.name;
  Expression<String> get documentGroupId => scannedDocuments.groupId;

  @override
  Query as() => select([groupId, groupName, docId, docName, documentGroupId])
      .from(groups)
      .join([
        innerJoin(
          scannedDocuments,
          scannedDocuments.groupId.equalsExp(groups.id),
        ),
      ]);
}

abstract class ScannedGroupDocCount extends View {
  ScannedDocumentsGroups get groups;
  ScannedDocuments get scannedDocuments;

  Expression<int> get docCount => scannedDocuments.id.count();

  @override
  Query as() => select([groups.id, groups.name, docCount]).from(groups).join([
    leftOuterJoin(
      scannedDocuments,
      scannedDocuments.groupId.equalsExp(groups.id),
    ),
  ])..groupBy([groups.id, groups.name]);
}
