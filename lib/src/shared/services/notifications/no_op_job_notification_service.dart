import 'i_job_notification_service.dart';

class NoopJobNotificationService implements IJobNotificationService {
  const NoopJobNotificationService();

  @override
  void initialize() {}

  @override
  Future<void> showOrUpdate({
    required String title,
    required String body,
    int? current,
    int? total,
  }) async {}

  @override
  Future<void> dismiss() async {}
}
