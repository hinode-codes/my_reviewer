import 'dart:math';

/// Retries [action] up to [maxAttempts] times while [shouldRetry] returns `true`.
///
/// Applies randomized jitter to prevent synchronized retry storms (thundering herd).
/// By default, uses exponential backoff (`baseDelay * 2^(attempt - 1)`) with full
/// jitter (`0ms` to `calculatedDelay`).
Future<T> retryAsync<T>(
  Future<T> Function(int attempt) action, {
  required bool Function(T result) shouldRetry,
  int maxAttempts = 3,
  Duration baseDelay = const Duration(seconds: 2),
  Duration? maxDelay,
  bool useJitter = true,
  Duration Function(int attempt)? delayBuilder,
  Random? random,
}) async {
  assert(maxAttempts >= 1);

  final rng = random ?? Random();
  late T lastResult;

  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    lastResult = await action(attempt);

    if (attempt >= maxAttempts || !shouldRetry(lastResult)) {
      return lastResult;
    }

    var delay =
        delayBuilder?.call(attempt) ??
        baseDelay * (1 << (attempt - 1)); // 2s, 4s, 8s...

    if (maxDelay != null && delay > maxDelay) {
      delay = maxDelay;
    }

    if (useJitter && delay > Duration.zero) {
      final halfMs = delay.inMilliseconds ~/ 2;
      final jitteredMs = halfMs + rng.nextInt(halfMs + 1);
      delay = Duration(milliseconds: jitteredMs);
    }

    await Future<void>.delayed(delay);
  }

  return lastResult;
}
