import 'dart:io';

import 'package:my_reviewer/src/shared/models/storage_root.dart';

abstract interface class IFileStorageService {
  Directory get appDocumentsDirectory;

  Directory get appSupportDirectory;

  Directory directoryFor(StorageRoot root);

  /// Resolves a relative path (e.g., stored in DB) to an absolute path at runtime.
  /// Crucial for iOS where app container sandbox GUIDs change across app updates.
  String resolveAbsolutePath(
    String relativePath, {
    StorageRoot root = defaultStorageRoot,
  });

  /// Ensures a nested directory structure exists relative to [root].
  /// Example: `ensureDirectory(['scanned_documents', groupId])`
  Future<Directory> ensureDirectory(
    List<String> subDirectories, {
    StorageRoot root = defaultStorageRoot,
  });

  /// Generic file copy into any nested directory structure.
  /// Preserves or appends file extensions automatically.
  /// Returns the relative file path.
  Future<String> saveFile(
    String src,
    List<String> dst, {
    required String fileNameWithoutExtension,
    StorageRoot root = defaultStorageRoot,
  });

  /// Names of everything directly inside [subDirectories], so new names can
  /// avoid them.
  Future<Set<String>> listEntryNames(
    List<String> subDirectories, {
    StorageRoot root = defaultStorageRoot,
  });

  /// Writes UTF-8 string [content] directly to `<dst>/<fileNameWithExtension>`
  /// relative to [root]. Overwrites if it already exists.
  /// Returns the relative file path.
  Future<String> saveText(
    String content,
    List<String> dst, {
    required String fileNameWithExtension,
    StorageRoot root = defaultStorageRoot,
  });

  /// Reads UTF-8 text from [relativePath] relative to [root].
  Future<String> readText(
    String relativePath, {
    StorageRoot root = defaultStorageRoot,
  });

  Future<void> rename(String from, String to);

  Future<void> delete(String path, {bool recursive = true});

  void deleteQuietly(String path, {bool recursive = true});
  void deleteQuietlyBatch(Iterable<String> paths);
}
