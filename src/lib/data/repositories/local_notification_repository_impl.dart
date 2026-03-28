// TODO: initialize timezone data in main.dart before using scheduleNotification:
//   import 'package:timezone/data/latest_all.dart' as tz;
//   tz.initializeTimeZones();

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vaccination_manager/domain/repositories/notification_repository.dart';

class LocalNotificationRepositoryImpl implements NotificationRepository {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  @override
  Future<bool> hasPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// TODO: Complete implementation — requires timezone initialisation in main.dart
  /// and AndroidScheduleMode / DarwinNotificationDetails configuration.
  @override
  Future<int> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // TODO: implement using plugin.zonedSchedule() once timezone data is
    // initialised in main.dart with tz.initializeTimeZones().
    return id;
  }

  /// TODO: Implement cancellation via _plugin.cancel(id)
  @override
  Future<void> cancel(int id) async {
    // TODO: await _plugin.cancel(id);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
