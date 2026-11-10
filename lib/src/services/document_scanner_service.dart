import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

abstract class IDocumentScannerService {
  /// Runs the Google ML Kit document scanner and returns a
  /// list of scanned temporary image paths.
  Future<List<String>?> scanDocument({int pageLimit});
}

class MlKitDocumentScannerService implements IDocumentScannerService {
  @override
  Future<List<String>?> scanDocument({int pageLimit = 10}) async {
    final options = DocumentScannerOptions(
      documentFormats: {DocumentFormat.jpeg},
      mode: ScannerMode.full,
      pageLimit: pageLimit,
      isGalleryImport: true,
    );

    final documentScanner = DocumentScanner(options: options);
    final DocumentScanningResult result = await documentScanner.scanDocument();

    if (result.images == null || result.images!.isEmpty) {
      return null;
    }

    return result.images;
  }
}
