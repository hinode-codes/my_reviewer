abstract interface class IDocumentScannerService {
  /// Runs the Google ML Kit document scanner and returns a
  /// list of scanned temporary image paths.
  Future<List<String>?> scanDocument({int pageLimit});
}
