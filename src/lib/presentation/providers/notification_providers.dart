import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/data/repositories/local_notification_repository_impl.dart';
import 'package:vaccination_manager/data/repositories/native_calendar_repository_impl.dart';
import 'package:vaccination_manager/data/repositories/synced_event_repository_impl.dart';
import 'package:vaccination_manager/domain/entities/notification_preference_entity.dart';
import 'package:vaccination_manager/domain/repositories/calendar_repository.dart';
import 'package:vaccination_manager/domain/repositories/notification_repository.dart';
import 'package:vaccination_manager/domain/repositories/synced_event_repository.dart';
import 'package:vaccination_manager/domain/usecases/notifications/cancel_notifications_use_case.dart';
import 'package:vaccination_manager/domain/usecases/notifications/export_ics_use_case.dart';
import 'package:vaccination_manager/domain/usecases/notifications/sync_calendar_use_case.dart';
import 'package:vaccination_manager/presentation/viewmodels/settings_viewmodel.dart';

final syncedEventRepositoryProvider = Provider<SyncedEventRepository>(
  (_) => SyncedEventRepositoryImpl(),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (_) => LocalNotificationRepositoryImpl(),
);

final calendarRepositoryProvider = Provider<CalendarRepository>(
  (_) => NativeCalendarRepositoryImpl(),
);

final syncCalendarUseCaseProvider = Provider<SyncCalendarUseCase>((ref) {
  return SyncCalendarUseCase(
    calendarRepo: ref.watch(calendarRepositoryProvider),
    notificationRepo: ref.watch(notificationRepositoryProvider),
    syncedEventRepo: ref.watch(syncedEventRepositoryProvider),
  );
});

final cancelNotificationsUseCaseProvider =
    Provider<CancelNotificationsUseCase>((ref) {
  return CancelNotificationsUseCase(
    calendarRepo: ref.watch(calendarRepositoryProvider),
    notificationRepo: ref.watch(notificationRepositoryProvider),
    syncedEventRepo: ref.watch(syncedEventRepositoryProvider),
  );
});

final exportIcsUseCaseProvider = Provider<ExportIcsUseCase>(
  (_) => const ExportIcsUseCase(),
);

final notificationPreferencesProvider =
    FutureProvider<NotificationPreferenceEntity>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getNotificationPreferences();
});
