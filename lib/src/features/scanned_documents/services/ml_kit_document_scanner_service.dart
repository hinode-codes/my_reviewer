import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

import 'i_document_scanner_service.dart';

class MlKitDocumentScannerService implements IDocumentScannerService {
  @override
  Future<List<String>?> scanDocument({int pageLimit = 10}) async {
    final options = DocumentScannerOptions(
      documentFormats: {DocumentFormat.jpeg},
      mode: ScannerMode.base,
      pageLimit: pageLimit,
      isGalleryImport: true,
    );
    final documentScanner = DocumentScanner(options: options);

    try {
      final DocumentScanningResult result = await documentScanner
          .scanDocument();

      if (result.images == null || result.images!.isEmpty) {
        return null;
      }

      return result.images;
    } finally {
      documentScanner.close();
    }
  }

  @override
  void dispose() {}
}
