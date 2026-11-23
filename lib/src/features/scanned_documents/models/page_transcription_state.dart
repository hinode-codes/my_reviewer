sealed class PageTranscriptionState {
  const PageTranscriptionState();
}

final class TranscriptionNotQueued extends PageTranscriptionState {
  const TranscriptionNotQueued();
}

final class TranscriptionQueued extends PageTranscriptionState {
  const TranscriptionQueued({
    required this.jobId,
    this.queuePosition,
    this.partialMarkdown,
  });

  final String jobId;
  final int? queuePosition;
  final String? partialMarkdown;
}

final class TranscriptionInProgress extends PageTranscriptionState {
  const TranscriptionInProgress({
    required this.jobId,
    required this.streamingMarkdown,
    required this.wordCount,
    required this.elapsedMs,
  });

  final String jobId;
  final String streamingMarkdown;
  final int wordCount;
  final int elapsedMs;
}

final class TranscriptionReady extends PageTranscriptionState {
  const TranscriptionReady({
    required this.markdown,
    required this.wordCount,
    required this.timeMsToRead,
    required this.timeMsToTranscribe,
  });

  final String markdown;
  final int wordCount;
  final int timeMsToRead;
  final int timeMsToTranscribe;
}

final class TranscriptionFailed extends PageTranscriptionState {
  const TranscriptionFailed({
    this.jobId,
    this.partialMarkdown,
    this.errorMessage,
  });

  final String? jobId;
  final String? partialMarkdown;
  final String? errorMessage;
}
