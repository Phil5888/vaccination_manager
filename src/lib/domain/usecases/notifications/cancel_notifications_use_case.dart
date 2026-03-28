import 'package:vaccination_manager/domain/repositories/calendar_repository.dart';
import 'package:vaccination_manager/domain/repositories/notification_repository.dart';
import 'package:vaccination_manager/domain/repositories/synced_event_repository.dart';

class CancelNotificationsUseCase {
  final CalendarRepository calendarRepo;
  final NotificationRepository notificationRepo;
  final SyncedEventRepository syncedEventRepo;

  const CancelNotificationsUseCase({
    required this.calendarRepo,
    required this.notificationRepo,
    required this.syncedEventRepo,
  });

  Future<void> callForShots(List<int> vaccinationIds) async {
    for (final id in vaccinationIds) {
      final records = await syncedEventRepo.getForShot(id);
      for (final r in records) {
        if (r.calendarEventId != null) {
          await calendarRepo.deleteEvent(r.calendarEventId!);
        }
        if (r.notificationId != null) {
          await notificationRepo.cancel(r.notificationId!);
        }
      }
      await syncedEventRepo.deleteForShot(id);
    }
  }
}
