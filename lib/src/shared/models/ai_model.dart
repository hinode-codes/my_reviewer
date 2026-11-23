import 'package:my_reviewer/src/shared/models/storage_root.dart';

enum AiModelCapability {
  ocrTranscription,
  // Future capabilities (e.g., textGeneration, embeddings) reuse the exact same pipeline.
}

enum AiModelFileRole { model, mmproj, adapter }

enum AiModelInstallPhase {
  notInstalled,
  partialDownload,
  downloadedUnverified,
  verifiedUnintegrated,
  ready,
  failed;

  bool get needsRecovery => switch (this) {
    partialDownload ||
    downloadedUnverified ||
    verifiedUnintegrated ||
    failed => true,
    notInstalled || ready => false,
  };
}

class AiModelArtifact {
  const AiModelArtifact({
    required this.id,
    required this.role,
    required this.fileName,
    required this.downloadUrl,
    required this.expectedBytes,
    this.sha256,
    this.optional = false,
  });

  final String id;
  final AiModelFileRole role;
  final String fileName;
  final String downloadUrl;
  final int expectedBytes;
  final String? sha256;
  final bool optional;
}

class AiModelSpec {
  const AiModelSpec({
    required this.id,
    required this.displayName,
    required this.subtitle,
    required this.capability,
    required this.artifacts,
    this.storageRoot = StorageRoot.support,
    this.requiresAuthToken = false,
  });

  final String id;
  final String displayName;
  final String subtitle;
  final AiModelCapability capability;
  final List<AiModelArtifact> artifacts;
  final StorageRoot storageRoot;
  final bool requiresAuthToken;

  List<String> get relativeSubDirectories => ['ai_models', id];

  int get totalBytes =>
      artifacts.fold<int>(0, (sum, artifact) => sum + artifact.expectedBytes);
}

class AiModelStatus {
  const AiModelStatus({
    required this.spec,
    required this.phase,
    this.downloadedBytes = 0,
    this.errorMessage,
  });

  final AiModelSpec spec;
  final AiModelInstallPhase phase;
  final int downloadedBytes;
  final String? errorMessage;
}
