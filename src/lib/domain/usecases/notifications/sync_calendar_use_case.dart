import 'package:vaccination_manager/domain/entities/notification_preference_entity.dart';
import 'package:vaccination_manager/domain/entities/synced_event_record.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/repositories/calendar_repository.dart';
import 'package:vaccination_manager/domain/repositories/notification_repository.dart';
import 'package:vaccination_manager/domain/repositories/synced_event_repository.dart';

/// Idempotent: removes any previously synced events/notifications for the
/// given shots, then creates fresh ones for shots with future dates.
class SyncCalendarUseCase {
  final CalendarRepository calendarRepo;
  final NotificationRepository notificationRepo;
  final SyncedEventRepository syncedEventRepo;

  const SyncCalendarUseCase({
    required this.calendarRepo,
    required this.notificationRepo,
    required this.syncedEventRepo,
  });

  Future<void> call({
    required List<VaccinationEntryEntity> shots,
    required NotificationPreferenceEntity prefs,
  }) async {
    for (final shot in shots) {
      if (shot.id == null) continue;

      // 1. Remove stale
      final existing = await syncedEventRepo.getForShot(shot.id!);
      for (final record in existing) {
        if (record.calendarEventId != null) {
          await calendarRepo.deleteEvent(record.calendarEventId!);
        }
        if (record.notificationId != null) {
          await notificationRepo.cancel(record.notificationId!);
        }
      }
      await syncedEventRepo.deleteForShot(shot.id!);

      // 2. Only sync shots with a future date
      final date = shot.vaccinationDate ?? shot.nextVaccinationDate;
      if (date == null || !date.isAfter(DateTime.now())) continue;

      final title =
          '💉 ${shot.name}${shot.totalShots > 1 ? ' — Shot ${shot.shotNumber} of ${shot.totalShots}' : ''}';
      const notes =
          'VaccineCare reminder — open the app to record this vaccination.';

      String? calendarEventId;
      if (prefs.calendarSyncEnabled && calendarRepo.supportsNativeCalendar) {
        calendarEventId = await calendarRepo.createEvent(
          title: title,
          date: date,
          notes: notes,
          alarmMinutesBefore: prefs.reminderAdvanceDays * 24 * 60,
        );
      }

      int? notificationId;
      if (prefs.notificationsEnabled) {
        final notifyDate =
            date.subtract(Duration(days: prefs.reminderAdvanceDays));
        if (notifyDate.isAfter(DateTime.now())) {
          final nid = shot.id! * 100 + shot.shotNumber; // stable ID
          await notificationRepo.scheduleNotification(
            id: nid,
            title: title,
            body: 'Due on ${date.toLocal()}',
            scheduledDate: notifyDate,
          );
          notificationId = nid;
        }
      }

      if (calendarEventId != null || notificationId != null) {
        await syncedEventRepo.insert(SyncedEventRecord(
          userId: shot.userId,
          vaccinationId: shot.id!,
          calendarEventId: calendarEventId,
          notificationId: notificationId,
          syncedAt: DateTime.now(),
        ));
      }
    }
  }
}
