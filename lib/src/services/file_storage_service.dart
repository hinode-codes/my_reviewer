// lib/src/services/file_storage_service.dart
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileStorageService {
  Future<Directory> get appDocumentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  /// Resolves a relative path (e.g., stored in DB) to an absolute path at runtime.
  /// Crucial for iOS where app container sandbox GUIDs change across app updates.
  Future<String> resolveAbsolutePath(String relativePath) async {
    final base = await appDocumentsDirectory;

    return p.join(base.path, relativePath);
  }

  /// Ensures a nested directory structure exists relative to app documents.
  /// Example: `ensureDirectory(['scanned_documents', groupId])`
  Future<Directory> ensureDirectory(List<String> subDirectories) async {
    final base = await appDocumentsDirectory;
    final dirPath = p.joinAll([base.path, ...subDirectories]);
    final dir = Directory(dirPath);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  /// Generic file copy into any nested directory structure.
  /// Preserves or appends file extensions automatically.
  /// Returns both relative (for DB storage) and absolute (for immediate disk access) paths.
  Future<({String relativePath, String absolutePath})> saveFile({
    required String sourcePath,
    required List<String> targetSubDirectories,
    required String fileNameWithoutExtension,
  }) async {
    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw FileSystemException('Source file does not exist', sourcePath);
    }

    final targetDir = await ensureDirectory(targetSubDirectories);
    final ext = p.extension(sourcePath);
    final fileName = '$fileNameWithoutExtension$ext';

    final absolutePath = p.join(targetDir.path, fileName);
    final relativePath = p.joinAll([...targetSubDirectories, fileName]);

    await sourceFile.copy(absolutePath);
    return (relativePath: relativePath, absolutePath: absolutePath);
  }

  /// Unified delete for files or directories.
  Future<void> delete(String path, {bool recursive = true}) async {
    final type = await FileSystemEntity.type(path);

    if (type == FileSystemEntityType.file) {
      await File(path).delete();
    } else if (type == FileSystemEntityType.directory) {
      await Directory(path).delete(recursive: recursive);
    }
  }

  /// Silent deletion helper for cleanup / transaction rollbacks (ignores errors).
  void deleteQuietly(String path, {bool recursive = true}) {
    try {
      final type = FileSystemEntity.typeSync(path);

      if (type == FileSystemEntityType.file) {
        File(path).deleteSync();
      } else if (type == FileSystemEntityType.directory) {
        Directory(path).deleteSync(recursive: recursive);
      }
    } catch (_) {}
  }

  void deleteQuietlyBatch(Iterable<String> paths) {
    for (final path in paths) {
      deleteQuietly(path);
    }
  }
}
