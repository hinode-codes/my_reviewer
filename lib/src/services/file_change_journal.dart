import 'package:my_reviewer/src/services/file_storage_service.dart';

typedef FileMove = ({String from, String to});

/// A move that passes through a temporary name on the way to its target.
typedef StagedMove = ({String from, String staging, String to});

/// Records every change one operation makes on disk, so the disk can be put
/// back when the database write it belongs to rolls back.
///
/// Create one per operation, make every disk change through it, and call
/// [rollback] from the operation's `catch`.
class FileChangeJournal {
  FileChangeJournal(this._storage);

  final FileStorageService _storage;
  final List<FileMove> _moves = [];
  final List<String> _createdFiles = [];

  Future<void> move(String from, String to) async {
    await _storage.rename(from, to);
    _moves.add((from: from, to: to));
  }

  void recordCreated(String path) => _createdFiles.add(path);

  /// Moves every file to its target without overwriting a file that another
  /// move in the same batch has not vacated yet.
  ///
  /// Two passes, because a page may take a name that another page only gives
  /// up later in the same loop; renaming straight to it would overwrite that
  /// page's image. Pass one parks every file under its staging name, pass
  /// two moves each one from there to its target.
  Future<void> moveAllViaStaging(
    List<StagedMove> moves, {
    required void Function() onEachFinalMove,
  }) async {
    for (final staged in moves) {
      await move(staged.from, staged.staging);
    }

    for (final staged in moves) {
      onEachFinalMove();
      await move(staged.staging, staged.to);
    }
  }

  /// Undoes everything recorded, best effort.
  ///
  /// Created files go first because they may sit inside a renamed folder,
  /// whose own rename is the last one undone.
  Future<void> rollback() async {
    _storage.deleteQuietlyBatch(_createdFiles);

    for (final completed in _moves.reversed) {
      try {
        await _storage.rename(completed.to, completed.from);
      } catch (_) {
        // Keep undoing the rest
      }
    }
  }
}
