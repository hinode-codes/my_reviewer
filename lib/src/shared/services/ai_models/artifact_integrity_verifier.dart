import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:my_reviewer/src/shared/models/ai_model.dart';
import 'package:path/path.dart' as p;

/// Validates that downloaded [AiModelArtifact] files exist and match their
/// expected SHA-256 digests.
class ArtifactIntegrityVerifier {
  const ArtifactIntegrityVerifier();

  /// Verifies all [artifacts] inside [directoryPath].
  ///
  /// Invokes [onCorruptedArtifact] before throwing [StateError] on a checksum
  /// mismatch so callers can delete corrupted files and downloader records.
  Future<void> verifyAll({
    required List<AiModelArtifact> artifacts,
    required String directoryPath,
    Future<void> Function(AiModelArtifact artifact, String filePath)?
    onCorruptedArtifact,
  }) async {
    for (final artifact in artifacts) {
      final filePath = p.join(directoryPath, artifact.fileName);
      final file = File(filePath);

      if (!await file.exists()) {
        throw FileSystemException('Missing downloaded artifact', filePath);
      }

      final expectedSha = artifact.sha256?.trim().toLowerCase();

      if (expectedSha == null || expectedSha.isEmpty) {
        continue;
      }

      final digest = await sha256.bind(file.openRead()).first;

      if (digest.toString().toLowerCase() != expectedSha) {
        await onCorruptedArtifact?.call(artifact, filePath);

        throw StateError(
          'Checksum mismatch for ${artifact.fileName} '
          '(expected $expectedSha, got $digest)',
        );
      }
    }
  }
}
