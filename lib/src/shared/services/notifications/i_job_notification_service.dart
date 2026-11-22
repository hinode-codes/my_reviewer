abstract interface class IJobNotificationService {
  /// Call once during app startup (e.g., in `main()`) to configure channels
  /// and communication ports before `showOrUpdate` is ever invoked.
  void initialize();

  /// Shows the persistent job notification if none is active, or updates the
  /// existing notification in place if already active.
  ///
  /// No-ops (and dismisses any active notification) if disabled by user
  /// preferences or if OS notification permission is not granted.
  Future<void> showOrUpdate({
    required String title,
    required String body,
    int? current,
    int? total,
  });

  /// Dismisses/stops the persistent job notification if active.
  Future<void> dismiss();
}
