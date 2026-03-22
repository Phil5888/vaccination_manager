import 'dart:convert';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:vaccination_manager/core/constants/reminder_lead_time.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';

class ReminderSyncResult {
  const ReminderSyncResult({required this.createdCalendarEntries, required this.updatedCalendarEntries, required this.removedCalendarEntries, required this.scheduledNotifications});

  final int createdCalendarEntries;
  final int updatedCalendarEntries;
  final int removedCalendarEntries;
  final int scheduledNotifications;
}

class ReminderSyncService {
  static const String _calendarIdKey = 'reminder_calendar_id';
  static const String _calendarMetaPrefix = 'reminder_calendar_meta_user_';

  final DeviceCalendarPlugin _calendarPlugin = DeviceCalendarPlugin();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  Future<ReminderSyncResult> syncForUser({required AppUserEntity user, required List<VaccinationSeriesEntity> series, required ReminderLeadTime leadTime}) async {
    final notificationsAvailable = await _initializeNotifications();

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final existingMeta = _loadMeta(prefs, user.id!);
    final activeKeys = <String>{};

    var created = 0;
    var updated = 0;
    var removed = 0;
    var scheduled = 0;

    final calendarId = await _resolveCalendarId(prefs);

    for (final item in series) {
      final key = _seriesKey(user.id!, item.name);
      activeKeys.add(key);

      final dueDate = _normalizeReminderDate(item.nextDueDateAt(now));
      final notificationId = _notificationIdFor(key);
      if (notificationsAvailable) {
        await _notifications.cancel(notificationId);
      }

      final notifyAt = dueDate.subtract(Duration(days: leadTime.days));
      if (notificationsAvailable && notifyAt.isAfter(now)) {
        await _notifications.zonedSchedule(
          notificationId,
          'Vaccination reminder',
          '${item.name} is due on ${_formatDate(dueDate)}',
          tz.TZDateTime.from(notifyAt, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails('vaccination_reminders', 'Vaccination reminders', channelDescription: 'Reminders for upcoming vaccinations', importance: Importance.high, priority: Priority.high),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
        scheduled += 1;
      }

      if (calendarId == null) {
        existingMeta[key] = {'notificationId': notificationId, 'dueDate': dueDate.toIso8601String()};
        continue;
      }

      final existing = existingMeta[key];
      final eventId = existing?['eventId'] as String?;

      final event = Event(calendarId, eventId: eventId, title: item.name, description: 'Vaccination due date', start: tz.TZDateTime.from(dueDate, tz.local), end: tz.TZDateTime.from(dueDate.add(const Duration(hours: 1)), tz.local));

      final result = await _calendarPlugin.createOrUpdateEvent(event);
      final savedEventId = result?.data;
      if (savedEventId != null) {
        if (eventId == null) {
          created += 1;
        } else {
          updated += 1;
        }
        existingMeta[key] = {'eventId': savedEventId, 'notificationId': notificationId, 'dueDate': dueDate.toIso8601String()};
      }
    }

    final staleKeys = existingMeta.keys.where((key) => !activeKeys.contains(key)).toList();
    for (final staleKey in staleKeys) {
      final stale = existingMeta.remove(staleKey);
      final notificationId = stale?['notificationId'] as int?;
      if (notificationsAvailable && notificationId != null) {
        await _notifications.cancel(notificationId);
      }

      final eventId = stale?['eventId'] as String?;
      if (calendarId != null && eventId != null) {
        await _calendarPlugin.deleteEvent(calendarId, eventId);
        removed += 1;
      }
    }

    await _saveMeta(prefs, user.id!, existingMeta);

    return ReminderSyncResult(createdCalendarEntries: created, updatedCalendarEntries: updated, removedCalendarEntries: removed, scheduledNotifications: scheduled);
  }

  Future<bool> _initializeNotifications() async {
    if (_initialized) {
      return true;
    }

    try {
      tz_data.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: androidSettings, iOS: darwinSettings);

      await _notifications.initialize(initSettings);

      await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      await _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);

      _initialized = true;
      return true;
    } on MissingPluginException {
      return false;
    }
  }

  Future<String?> _resolveCalendarId(SharedPreferences prefs) async {
    final permissionResult = await _calendarPlugin.requestPermissions();
    if (!(permissionResult.data ?? false)) {
      return null;
    }

    final storedId = prefs.getString(_calendarIdKey);
    if (storedId != null && storedId.isNotEmpty) {
      return storedId;
    }

    final calendarsResult = await _calendarPlugin.retrieveCalendars();
    final calendars = calendarsResult.data ?? const <Calendar>[];

    for (final calendar in calendars) {
      if (!(calendar.isReadOnly ?? false)) {
        final id = calendar.id;
        if (id != null && id.isNotEmpty) {
          await prefs.setString(_calendarIdKey, id);
          return id;
        }
      }
    }

    return null;
  }

  Map<String, Map<String, Object>> _loadMeta(SharedPreferences prefs, int userId) {
    final raw = prefs.getString('$_calendarMetaPrefix$userId');
    if (raw == null || raw.isEmpty) {
      return <String, Map<String, Object>>{};
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return <String, Map<String, Object>>{};
    }

    final result = <String, Map<String, Object>>{};
    decoded.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        result[key] = <String, Object>{
          for (final entry in value.entries)
            if (entry.value != null) entry.key: entry.value as Object,
        };
      }
    });
    return result;
  }

  Future<void> _saveMeta(SharedPreferences prefs, int userId, Map<String, Map<String, Object>> value) async {
    await prefs.setString('$_calendarMetaPrefix$userId', jsonEncode(value));
  }

  String _seriesKey(int userId, String seriesName) => '$userId|${seriesName.trim().toLowerCase()}';

  int _notificationIdFor(String key) => key.hashCode & 0x7fffffff;

  DateTime _normalizeReminderDate(DateTime value) => DateTime(value.year, value.month, value.day, 9);

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}
