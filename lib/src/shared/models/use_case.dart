import 'package:my_reviewer/src/shared/models/task.dart';

/// Shared contract for all multi-step application use cases that report progress
/// and return a result [R].
abstract interface class UseCase<Params, R> {
  Future<R> call(Params params, {MyReviewerTaskProgressCallback? onProgress});
}

/// Convenience contract for use cases that require no parameters.
abstract interface class NoParamsUseCase<R> {
  Future<R> call({MyReviewerTaskProgressCallback? onProgress});
}
