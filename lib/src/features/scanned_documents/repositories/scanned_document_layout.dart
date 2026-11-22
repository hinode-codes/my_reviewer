import 'package:my_reviewer/src/features/scanned_documents/models/pending_scan_page.dart';
import 'package:my_reviewer/src/features/scanned_documents/models/scanned_document_model.dart';
import 'package:my_reviewer/src/features/scanned_documents/utils/unique_name_allocator.dart';
import 'package:my_reviewer/src/shared/services/storage/i_file_storage_service.dart';
import 'package:my_reviewer/src/shared/utils/strings.dart';
import 'package:path/path.dart' as p;

typedef GroupFolder = ({String name, String relative, String absolute});

class PlannedPage {
  const PlannedPage({
    required this.id,
    required this.name,
    required this.ext,
    required this.sourceAbsolutePath,
    required this.currentRelativePath,
    required this.fileNameWithoutExtension,
    required this.relativePath,
    required this.absolutePath,
  });

  final String id;
  final String name;
  final String ext;

  /// Non-null for newly captured/imported pages being copied into the group folder.
  final String? sourceAbsolutePath;

  /// Non-null for existing pages already stored inside the group folder.
  final String? currentRelativePath;

  final String fileNameWithoutExtension;
  final String relativePath;
  final String absolutePath;

  String get currentFileNameWithExtension => p.basename(currentRelativePath!);
  String get targetFileNameWithExtension => p.basename(relativePath);
}

class ScannedDocumentLayout {
  const ScannedDocumentLayout(this._storage);

  final IFileStorageService _storage;

  static const String rootFolder = 'scanned_documents';
  static const String _renameStagingPrefix = '.renaming_';

  List<String> folderSegments(String folderName) => [rootFolder, folderName];

  String relativePath(String folderName) => p.join(rootFolder, folderName);

  String stagingPathFor(GroupFolder folder, String documentId) =>
      p.join(folder.absolute, '$_renameStagingPrefix$documentId');

  Future<String> claimFolderName(
    String desiredName,
    String fallback, {
    String? current,
  }) async {
    final base = sanitizeFileName(desiredName, fallback);
    final siblings = await _storage.listEntryNames([rootFolder]);

    return UniqueNameAllocator(siblings.where((name) => name != current))
        .claim(base);
  }

  List<PlannedPage> planExistingPages(
    List<ScannedDocumentModel> documents, {
    required String groupName,
    required GroupFolder folder,
    required UniqueNameAllocator names,
    int indexOffset = 0,
  }) {
    return [
      for (int i = 0; i < documents.length; ++i)
        _plan(
          id: documents[i].id,
          name: documents[i].name,
          ext: documents[i].ext,
          currentRelativePath: documents[i].relativePath,
          fileName: names.claim(
            sanitizeFileName(
              documents[i].name,
              ScannedDocumentModel.fallbackFileName(groupName, indexOffset + i),
            ),
            extension: documents[i].ext,
          ),
          folder: folder,
        ),
    ];
  }

  List<PlannedPage> planNewPages(
    List<PendingScanPage> pages, {
    required String groupName,
    required GroupFolder folder,
    required UniqueNameAllocator names,
    int indexOffset = 0,
  }) {
    return [
      for (int i = 0; i < pages.length; ++i)
        _plan(
          id: pages[i].id,
          name: pages[i].name,
          ext: pages[i].ext,
          sourceAbsolutePath: pages[i].sourceAbsolutePath,
          fileName: names.claim(
            sanitizeFileName(
              pages[i].name,
              ScannedDocumentModel.fallbackFileName(groupName, indexOffset + i),
            ),
            extension: pages[i].ext,
          ),
          folder: folder,
        ),
    ];
  }

  PlannedPage _plan({
    required String id,
    required String name,
    required String ext,
    required String fileName,
    required GroupFolder folder,
    String? sourceAbsolutePath,
    String? currentRelativePath,
  }) {
    final fileNameWithExt = '$fileName.$ext';

    return PlannedPage(
      id: id,
      name: name,
      ext: ext,
      sourceAbsolutePath: sourceAbsolutePath,
      currentRelativePath: currentRelativePath,
      fileNameWithoutExtension: fileName,
      relativePath: p.join(folder.relative, fileNameWithExt),
      absolutePath: p.join(folder.absolute, fileNameWithExt),
    );
  }
}
