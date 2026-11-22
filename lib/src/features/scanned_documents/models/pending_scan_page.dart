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
}
