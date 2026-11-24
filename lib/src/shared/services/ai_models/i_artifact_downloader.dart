import 'package:my_reviewer/src/shared/models/artifact_download.dart';

/// Stage updates pushed to the active OS download notification after file
/// transfer completes.
enum ArtifactNotificationStage { verifying, integrating, complete, failed }

/// Abstraction over `background_downloader` for testable artifact transfers.
abstract interface class IArtifactDownloader {
  Future<List<ArtifactDownloadRecord>> recordsForGroup(String group);

  Future<ArtifactDownloadRecord?> recordForTask(String taskId);

  Future<void> deleteRecord(String taskId);

  Future<void> cancelAndDeleteGroup(String group);

  void configureGroupNotifications({
    required String group,
    required String displayName,
  });

  Future<ArtifactDownloadResult> downloadOrResume({
    required String group,
    required String taskId,
    required String url,
    required String fileName,
    required String directoryPath,
    required bool requiresWiFi,
    String? authToken,
    required void Function(double fraction) onProgress,
  });
}
