import "dart:io";

import "package:my_reviewer/src/shared/models/storage_root.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

import "i_file_storage_service.dart";

class DiskFileStorageService implements IFileStorageService {
  const DiskFileStorageService._({
    required this.appDocumentsDirectory,
    required this.appSupportDirectory,
  });

  static Future<DiskFileStorageService> create() async {
    final (docsDir, supportDir) = await (
      getApplicationDocumentsDirectory(),
      getApplicationSupportDirectory(),
    ).wait;

    return DiskFileStorageService._(
      appDocumentsDirectory: docsDir,
      appSupportDirectory: supportDir,
    );
  }

  @override
  final Directory appDocumentsDirectory;

  @override
  final Directory appSupportDirectory;

  @override
  Directory directoryFor(StorageRoot root) => switch (root) {
    StorageRoot.documents => appDocumentsDirectory,
    StorageRoot.support => appSupportDirectory,
  };

  @override
  String resolveAbsolutePath(
    String relativePath, {
    StorageRoot root = defaultStorageRoot,
  }) {
    return p.join(directoryFor(root).path, relativePath);
  }

  @override
  Future<void> delete(String path, {bool recursive = true}) async {
    final entity = await _entityAt(path);

    if (entity is Directory) {
      await entity.delete(recursive: recursive);
    } else {
      await entity?.delete();
    }
  }

  @override
  void deleteQuietly(String path, {bool recursive = true}) {
    // Cleanup and rollback paths must never throw, whatever the disk says.
    try {
      final entity = _entityAtSync(path);

      if (entity is Directory) {
        entity.deleteSync(recursive: recursive);
      } else {
        entity?.deleteSync();
      }
    } catch (_) {}
  }

  @override
  void deleteQuietlyBatch(Iterable<String> paths) =>
      paths.forEach(deleteQuietly);

  Directory _directoryAt(List<String> subDirectories, StorageRoot root) {
    final base = directoryFor(root);

    return Directory(p.joinAll([base.path, ...subDirectories]));
  }

  @override
  Future<Directory> ensureDirectory(
    List<String> subDirectories, {
    StorageRoot root = defaultStorageRoot,
  }) async {
    final dir = _directoryAt(subDirectories, root);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  Future<FileSystemEntity?> _entityAt(String path) async =>
      _entityOfType(await FileSystemEntity.type(path), path);

  FileSystemEntity? _entityAtSync(String path) =>
      _entityOfType(FileSystemEntity.typeSync(path), path);

  FileSystemEntity? _entityOfType(FileSystemEntityType typ, String path) =>
      switch (typ) {
        FileSystemEntityType.file => File(path),
        FileSystemEntityType.directory => Directory(path),
        _ => null,
      };

  @override
  Future<Set<String>> listEntryNames(
    List<String> subDirectories, {
    StorageRoot root = defaultStorageRoot,
  }) async {
    final dir = _directoryAt(subDirectories, root);

    if (!await dir.exists()) {
      return {};
    }

    return {await for (final entity in dir.list()) p.basename(entity.path)};
  }

  @override
  Future<String> saveText(
    String content,
    List<String> dst, {
    required String fileNameWithExtension,
    StorageRoot root = defaultStorageRoot,
  }) async {
    final dir = await ensureDirectory(dst, root: root);
    final relativePath = p.joinAll([...dst, fileNameWithExtension]);
    final file = File(p.join(dir.path, fileNameWithExtension));

    await file.writeAsString(content, flush: true);

    return relativePath;
  }

  @override
  Future<String> readText(
    String relativePath, {
    StorageRoot root = defaultStorageRoot,
  }) async {
    final absolutePath = resolveAbsolutePath(relativePath, root: root);

    return File(absolutePath).readAsString();
  }

  @override
  Future<void> rename(String from, String to) async {
    final entity = await _entityAt(from);

    if (entity == null) {
      throw FileSystemException("Nothing to rename", from);
    }

    await entity.rename(to);
  }

  @override
  Future<String> saveFile(
    String src,
    List<String> dst, {
    required String fileNameWithoutExtension,
    StorageRoot root = defaultStorageRoot,
  }) async {
    final source = File(src);

    if (!await source.exists()) {
      throw FileSystemException("Source file does not exist", src);
    }

    final targetDir = await ensureDirectory(dst, root: root);
    final fileName = "$fileNameWithoutExtension${p.extension(src)}";

    await source.copy(p.join(targetDir.path, fileName));

    return p.joinAll([...dst, fileName]);
  }
}
