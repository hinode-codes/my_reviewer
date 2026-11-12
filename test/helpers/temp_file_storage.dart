import 'dart:io';

import 'package:my_reviewer/src/services/file_storage_service.dart';
import 'package:path/path.dart' as p;

/// The real [FileStorageService], rooted in a fresh temp folder instead of
/// the app documents folder, so tests touch a real disk without the
/// path_provider plugin.
class TempFileStorage extends FileStorageService {
  TempFileStorage._(this.root);

  /// Creates the temp root. Call [dispose] in tearDown.
  static Future<TempFileStorage> create() async =>
      TempFileStorage._(await Directory.systemTemp.createTemp('my_reviewer_'));

  final Directory root;

  @override
  Future<Directory> get appDocumentsDirectory async => root;

  /// Absolute path of [relative] under the root.
  String pathOf(String relative) => p.join(root.path, relative);

  /// Writes [contents] to [relative], creating parent folders.
  Future<String> write(String relative, String contents) async {
    final file = File(pathOf(relative));
    await file.parent.create(recursive: true);
    await file.writeAsString(contents);
    return file.path;
  }

  Future<void> dispose() => root.delete(recursive: true);
}