class JobExecutionContext {
  const JobExecutionContext({required this._onCheckpoint});

  final Future<bool> Function({String? partialOutput, int? elapsedMs})
  _onCheckpoint;

  /// Persists heartbeat + streamed partial output (for Qwen-VL prefill
  /// resumption). Returns `false` if the job was cancelled mid-run.
  Future<bool> checkpoint({String? partialOutput, int? elapsedMs}) =>
      _onCheckpoint(partialOutput: partialOutput, elapsedMs: elapsedMs);
}
