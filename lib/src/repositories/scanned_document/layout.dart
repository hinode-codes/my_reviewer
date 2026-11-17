import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/services/file_storage_service.dart';
import 'package:my_reviewer/src/utils/string.dart';
import 'package:my_reviewer/src/utils/unique_name_allocator.dart';
import 'package:path/path.dart' as p;

/// A group's folder: its name, its path relative to storage, and its path on
/// this device.
typedef GroupFolder = ({String name, String relative, String absolute});

/// Where one page's file will live once the operation finishes.
class PlannedPage {
  const PlannedPage({
    required this.document,
    required this.fileNameWithoutExtension,
    required this.relativePath,
    required this.absolutePath,
  });

  final ScannedDocumentModel document;

  final String fileNameWithoutExtension;
  final String relativePath;
  final String absolutePath;

  String get currentFileNameWithExtension =>
      p.basename(document.relativeFilePath);
  String get targetFileNameWithExtension => p.basename(relativePath);
}

/// Decides the names and paths of group folders and page files.
///
/// It reads the root folder to avoid collisions but never moves or writes
/// anything; the repository does that.
class ScannedDocumentLayout {
  const ScannedDocumentLayout(this._storage);

  final FileStorageService _storage;

  static const String rootFolder = 'scanned_documents';

  /// Hidden, id-based names a renamed file passes through on its way to its
  /// new name (see `FileChangeJournal.moveAllViaStaging`).
  static const String _renameStagingPrefix = '.renaming_';

  List<String> folderSegments(String folderName) => [rootFolder, folderName];

  String relativePath(String folderName) => p.join(rootFolder, folderName);

  String stagingPathFor(GroupFolder folder, String documentId) =>
      p.join(folder.absolute, '$_renameStagingPrefix$documentId');

  /// A folder per group, never shared: a shared folder would be wiped for
  /// both groups when either one is deleted.
  Future<String> claimFolderName(
    String desiredName,
    String fallback, {
    String? current,
  }) async {
    final base = sanitizeFileName(desiredName, fallback);
    final siblings = await _storage.listEntryNames([rootFolder]);

    // The group's own folder is not a collision; counting it would give an
    // unchanged name a new suffix and move the folder for nothing.
    return UniqueNameAllocator(siblings.where((name) => name != current))
        .claim(base);
  }

  /// Gives every document a unique file name inside [folder].
  ///
  /// [names] is shared between calls that plan into the same folder, so
  /// existing and new pages never get the same name. [indexOffset] keeps
  /// fallback names numbered after the pages planned before.
  List<PlannedPage> planPages(
    List<ScannedDocumentModel> documents, {
    required String groupName,
    required GroupFolder folder,
    required UniqueNameAllocator names,
    int indexOffset = 0,
  }) {
    return [
      for (int i = 0; i < documents.length; ++i)
        _planPage(
          documents[i],
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

  PlannedPage _planPage(
    ScannedDocumentModel document, {
    required String fileName,
    required GroupFolder folder,
  }) {
    final fileNameWithExt = '$fileName.${document.ext}';

    return PlannedPage(
      document: document,
      fileNameWithoutExtension: fileName,
      relativePath: p.join(folder.relative, fileNameWithExt),
      absolutePath: p.join(folder.absolute, fileNameWithExt),
    );
  }
}
