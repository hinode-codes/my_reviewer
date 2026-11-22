class JobCancelledException implements Exception {
  const JobCancelledException(this.jobId);
  final String jobId;

  @override
  String toString() => 'JobCancelledException: job $jobId was cancelled';
}
