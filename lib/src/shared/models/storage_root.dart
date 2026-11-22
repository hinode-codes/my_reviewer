enum StorageRoot {
  /// User-facing documents (scanned files, markdown transcriptions).
  documents,

  /// Internal app support files (downloaded AI models, extracted adapters).
  support,
}

/// Root used when a caller does not name one. Shared by the interface and
/// every implementation so the default lives in one place.
const StorageRoot defaultStorageRoot = StorageRoot.documents;
