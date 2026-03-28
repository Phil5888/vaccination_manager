abstract class NotificationRepository {
  Future<bool> requestPermission();
  Future<bool> hasPermission();

  /// Schedule a notification. Returns the notification ID used.
  Future<int> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  });

  Future<void> cancel(int id);
  Future<void> cancelAll();
}
