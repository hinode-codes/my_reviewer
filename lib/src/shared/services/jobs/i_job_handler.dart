import 'package:my_reviewer/src/shared/models/job_model.dart';
import 'package:my_reviewer/src/shared/services/jobs/job_execution_context.dart';

abstract interface class IJobHandler {
  Future<void> execute(JobModel job, JobExecutionContext context);
  void dispose();
}
