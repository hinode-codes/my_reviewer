enum DocsSelectionMode {
  inactive,
  active;

  bool get isActive => this == DocsSelectionMode.active;
}
