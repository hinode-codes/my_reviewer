abstract interface class ILocalOcrEngine {
  /// Ensures the Qwen-VL model and vision projector are loaded into memory.
  /// Safe to call repeatedly; no-ops if already initialized.
  Future<void> warmUp();

  /// Streams transcribed text chunks for the image at [absoluteImagePath].
  ///
  /// When [prefillText] is non-empty, feeds it as an unclosed assistant prefix
  /// so Qwen-VL continues from the exact stopping point without repeating
  /// earlier lines.
  Stream<String> transcribeImage({
    required String absoluteImagePath,
    String? prefillText,
  });

  /// Releases native model/KV-cache memory when the job queue goes idle or
  /// the app is disposed.
  Future<void> dispose();
}
