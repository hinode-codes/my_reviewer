class PendingScanPage {
  const PendingScanPage({
    required this.id,
    required this.name,
    required this.sourceAbsolutePath,
    required this.ext,
  });

  final String id;
  final String name;
  final String sourceAbsolutePath;
  final String ext;

  PendingScanPage copyWith({
    String? id,
    String? name,
    String? sourceAbsolutePath,
    String? ext,
  }) {
    return PendingScanPage(
      id: id ?? this.id,
      name: name ?? this.name,
      sourceAbsolutePath: sourceAbsolutePath ?? this.sourceAbsolutePath,
      ext: ext ?? this.ext,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingScanPage &&
          other.id == id &&
          other.name == name &&
          other.sourceAbsolutePath == sourceAbsolutePath &&
          other.ext == ext;

  @override
  int get hashCode => Object.hash(id, name, sourceAbsolutePath, ext);
}
