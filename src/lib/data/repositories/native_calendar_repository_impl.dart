import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vaccination_manager/domain/repositories/calendar_repository.dart';

/// Composite event ID format stored in [SyncedEventRecord.calendarEventId]:
///   `"calendarId::platformEventId"`
class NativeCalendarRepositoryImpl implements CalendarRepository {
  // Lazily instantiated so the plugin is not created until first actual use.
  DeviceCalendarPlugin? _calendarPluginInstance;
  DeviceCalendarPlugin get _calendarPlugin =>
      _calendarPluginInstance ??= DeviceCalendarPlugin();

  /// Separator used to join calendarId and eventId into a single stored string.
  static const _sep = '::';

  @override
  bool get supportsNativeCalendar => Platform.isAndroid || Platform.isIOS;

  @override
  Future<String?> createEvent({
    required String title,
    required DateTime date,
    required String notes,
    required int alarmMinutesBefore,
  }) async {
    if (!supportsNativeCalendar) return null;
    try {
      // Request calendar permissions if needed
      final permResult = await _calendarPlugin.hasPermissions();
      final hasPerm = permResult.data ?? false;
      if (!hasPerm) {
        final reqResult = await _calendarPlugin.requestPermissions();
        if (!(reqResult.data ?? false)) return null;
      }

      // Find the first writable calendar
      final calendarsResult = await _calendarPlugin.retrieveCalendars();
      final calendars = calendarsResult.data
              ?.where((c) => !(c.isReadOnly ?? true))
              .toList() ??
          [];
      if (calendars.isEmpty) return null;
      final calendarId = calendars.first.id!;

      // Build the event using UTC to avoid requiring full tz database init
      final startTz = tz.TZDateTime.from(date, tz.UTC);
      final endTz =
          tz.TZDateTime.from(date.add(const Duration(hours: 1)), tz.UTC);

      final event = Event(
        calendarId,
        title: title,
        description: notes,
        start: startTz,
        end: endTz,
        reminders: [Reminder(minutes: alarmMinutesBefore)],
      );

      final result = await _calendarPlugin.createOrUpdateEvent(event);
      final platformEventId = result?.data;
      if (platformEventId == null) return null;

      // Store composite "calendarId::eventId" so we can delete later
      return '$calendarId$_sep$platformEventId';
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    if (!supportsNativeCalendar) return;
    try {
      final parts = eventId.split(_sep);
      if (parts.length < 2) return;
      final calendarId = parts[0];
      final platformEventId = parts.sublist(1).join(_sep);
      await _calendarPlugin.deleteEvent(calendarId, platformEventId);
    } catch (_) {
      // No-op if event not found or permission denied
    }
  }

  @override
  String exportIcs({
    required String title,
    required DateTime date,
    required String notes,
    required int alarmMinutesBefore,
  }) {
    final sb = StringBuffer();
    final dtStamp = _formatDate(DateTime.now().toUtc());
    final dtStart = _formatDate(date.toUtc());
    final uid =
        'vaccinecare-${date.millisecondsSinceEpoch}-${title.hashCode}@vaccinecare';

    sb.writeln('BEGIN:VCALENDAR');
    sb.writeln('VERSION:2.0');
    sb.writeln('PRODID:-//VaccineCare//EN');
    sb.writeln('CALSCALE:GREGORIAN');
    sb.writeln('METHOD:PUBLISH');
    sb.writeln('BEGIN:VEVENT');
    sb.writeln('UID:$uid');
    sb.writeln('DTSTAMP:$dtStamp');
    sb.writeln('DTSTART;VALUE=DATE:${dtStart.substring(0, 8)}');
    sb.writeln('SUMMARY:$title');
    sb.writeln('DESCRIPTION:$notes');
    sb.writeln('BEGIN:VALARM');
    sb.writeln('TRIGGER:-PT${alarmMinutesBefore}M');
    sb.writeln('ACTION:DISPLAY');
    sb.writeln('DESCRIPTION:Vaccination reminder');
    sb.writeln('END:VALARM');
    sb.writeln('END:VEVENT');
    sb.writeln('END:VCALENDAR');
    return sb.toString();
  }

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}'
        'T${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}'
        '${dt.second.toString().padLeft(2, '0')}Z';
  }
}
