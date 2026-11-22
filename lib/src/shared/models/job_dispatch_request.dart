class JobDispatchRequest {
  const JobDispatchRequest({
    required this.id,
    required this.payload,
    this.groupKey,
    this.itemKey,
    this.runAfter,
    this.maxAttempts = 3,
    this.deduplicateActiveByItemKey = true,
  });

  final String id;
  final String payload;
  final String? groupKey;
  final String? itemKey;
  final DateTime? runAfter;
  final int maxAttempts;
  final bool deduplicateActiveByItemKey;
}
