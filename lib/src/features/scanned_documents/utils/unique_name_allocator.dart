const String _duplicateSeparator = '_';
const int _firstDuplicateNumber = 2;

/// Hands out names that do not collide with each other or with [taken].
///
/// `File.copy` and `rename` silently overwrite, so two pages named alike
/// would otherwise lose one image, and two groups named alike would share
/// (and, on delete, wipe) one folder.
///
/// Compared case-insensitively because iOS's default file system is, so
/// `Page` and `page` are the same file there.
class UniqueNameAllocator {
  UniqueNameAllocator(Iterable<String> taken)
    : _taken = {for (final name in taken) name.toLowerCase()};

  final Set<String> _taken;

  /// Returns [base], or `base_2`, `base_3`, … if it is taken, and reserves it.
  String claim(String base, {String extension = ''}) {
    var candidate = base;
    var number = _firstDuplicateNumber;

    while (!_taken.add(_key(candidate, extension))) {
      candidate = '$base$_duplicateSeparator$number';
      number++;
    }

    return candidate;
  }

  String _key(String name, String extension) =>
      (extension.isEmpty ? name : '$name.$extension').toLowerCase();
}
