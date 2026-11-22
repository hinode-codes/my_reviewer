import "package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_dao.dart";
import "package:my_reviewer/src/features/scanned_documents/db/dao/scanned_document_groups_dao.dart";
import "package:my_reviewer/src/features/scanned_documents/models/scanned_document_group_model.dart";
import "package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart";

import "i_scanned_document_read_repository.dart";
import "scanned_document_row_mapper.dart";

class LocalScannedDocumentReadRepository
    implements IScannedDocumentReadRepository {
  LocalScannedDocumentReadRepository({
    required this.groupsDao,
    required this.docsDao,
  }) : _mapper = ScannedDocumentRowMapper(docsDao: docsDao);

  final ScannedDocumentGroupsDao groupsDao;
  final ScannedDocumentDao docsDao;
  final ScannedDocumentRowMapper _mapper;

  @override
  Future<List<ScannedDocumentGroupModel>> getAllScannedDocumentGroups() async =>
      _mapper.groups(await groupsDao.getAllActiveGroups());

  @override
  Future<ScannedDocumentGroupModel> getScannedDocumentGroup(
    String groupId,
  ) async => _mapper.group(await groupsDao.getGroup(groupId));

  @override
  Future<List<ScannedDocumentModel>> getScannedDocumentsByGroupId(
    String groupId,
  ) async => _mapper.documents(await docsDao.getDocumentsForGroup(groupId));

  @override
  Future<bool> hasDocuments(String groupId) => docsDao.hasDocuments(groupId);

  @override
  Stream<String?> watchScannedDocumentGroupName(String groupId) =>
      groupsDao.watchGroupName(groupId);

  @override
  Stream<List<ScannedDocumentGroupModel>> watchScannedDocumentGroups() =>
      groupsDao.watchAllActiveGroups().asyncMap(_mapper.groups);

  @override
  Stream<List<ScannedDocumentModel>> watchScannedDocumentsByGroupId(
    String groupId,
  ) => docsDao.watchDocumentsForGroup(groupId).map(_mapper.documents);
}
