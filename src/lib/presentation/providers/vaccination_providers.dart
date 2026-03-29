import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/data/repositories/settings_repository.dart';
import 'package:vaccination_manager/domain/entities/reminder_status.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/domain/usecases/notifications/sync_calendar_use_case.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/get_vaccination_reminders_use_case.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/get_vaccinations_for_user_use_case.dart';
import 'package:vaccination_manager/presentation/providers/notification_providers.dart';
import 'package:vaccination_manager/presentation/providers/user_providers.dart';
import 'package:vaccination_manager/presentation/providers/vaccination_dependency_providers.dart';
import 'package:vaccination_manager/presentation/viewmodels/settings_viewmodel.dart';

// ---------------------------------------------------------------------------
// VaccinationViewModel
// ---------------------------------------------------------------------------

class VaccinationViewModel
    extends AsyncNotifier<List<VaccinationEntryEntity>> {
  @override
  Future<List<VaccinationEntryEntity>> build() async {
    final user = await ref.watch(activeUserProvider.future);
    if (user == null) return [];
    final useCase = ref.read(getVaccinationsForUserUseCaseProvider);
    return useCase.call(user.id!);
  }

  Future<void> saveVaccination(VaccinationEntryEntity entry) async {
    final useCase = ref.read(saveVaccinationUseCaseProvider);
    await useCase.call(entry);
    ref.invalidateSelf();
    ref.invalidate(vaccinationRemindersProvider);
  }

  Future<void> saveSeries(
    List<VaccinationEntryEntity> shots, {
    String? oldName,
  }) async {
    // Capture every dependency synchronously before any await/invalidate so
    // we never touch ref after the notifier is disposed by invalidateSelf().
    final saveUseCase = ref.read(saveVaccinationSeriesUseCaseProvider);
    final getUseCase = ref.read(getVaccinationsForUserUseCaseProvider);
    final syncUseCase = ref.read(syncCalendarUseCaseProvider);
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final user = await ref.read(activeUserProvider.future);

    await saveUseCase.call(shots, oldName: oldName);
    ref.invalidateSelf();
    ref.invalidate(vaccinationRemindersProvider);

    // Fire-and-forget: sync calendar/notifications after save.
    // Never awaited — the screen must not be blocked by this.
    if (user != null && shots.isNotEmpty) {
      final seriesName = shots.first.name.toLowerCase();
      _syncInBackground(
        getUseCase: getUseCase,
        syncUseCase: syncUseCase,
        settingsRepo: settingsRepo,
        userId: user.id!,
        seriesName: seriesName,
      );
    }
  }

  /// Runs the calendar/notification sync in a detached microtask so it never
  /// blocks the calling screen. All ref reads were captured before this runs.
  static void _syncInBackground({
    required GetVaccinationsForUserUseCase getUseCase,
    required SyncCalendarUseCase syncUseCase,
    required SettingsRepository settingsRepo,
    required int userId,
    required String seriesName,
  }) {
    Future<void>(() async {
      try {
        final allShots = await getUseCase.call(userId);
        final savedShots = allShots
            .where((s) => s.name.toLowerCase() == seriesName)
            .toList();
        final prefs = await settingsRepo.getNotificationPreferences();
        await syncUseCase(shots: savedShots, prefs: prefs);
      } catch (_) {
        // Sync is best-effort; never crash the app over a notification error.
      }
    });
  }

  Future<void> deleteShot(int id) async {
    // Capture cancel use case synchronously before any await.
    final cancelUseCase = ref.read(cancelNotificationsUseCaseProvider);

    try {
      await cancelUseCase.callForShots([id]);
    } catch (_) {
      // Cancel is best-effort.
    }

    final useCase = ref.read(deleteVaccinationShotUseCaseProvider);
    await useCase.call(id);
    ref.invalidateSelf();
    ref.invalidate(vaccinationRemindersProvider);
  }

  Future<void> deleteSeries(int userId, String name) async {
    // Capture refs and current shot IDs synchronously before any await.
    final cancelUseCase = ref.read(cancelNotificationsUseCaseProvider);
    final nameLower = name.toLowerCase();
    final currentEntries = state.when(
      data: (v) => v,
      loading: () => <VaccinationEntryEntity>[],
      error: (_, _) => <VaccinationEntryEntity>[],
    );
    final shotIds = currentEntries
        .where((s) =>
            s.userId == userId &&
            s.name.toLowerCase() == nameLower &&
            s.id != null)
        .map((s) => s.id!)
        .toList();

    try {
      if (shotIds.isNotEmpty) {
        await cancelUseCase.callForShots(shotIds);
      }
    } catch (_) {}

    final useCase = ref.read(deleteVaccinationSeriesUseCaseProvider);
    await useCase.call(userId, name);
    ref.invalidateSelf();
    ref.invalidate(vaccinationRemindersProvider);
  }
}

final vaccinationProvider =
    AsyncNotifierProvider<VaccinationViewModel, List<VaccinationEntryEntity>>(
  VaccinationViewModel.new,
);

// ---------------------------------------------------------------------------
// ScheduleViewModel – filter state for the Schedule screen
// ---------------------------------------------------------------------------

/// Possible filter values for the Schedule screen.
enum ReminderFilter { all, overdue, dueSoon, upToDate }

class ScheduleViewModel extends Notifier<ReminderFilter> {
  @override
  ReminderFilter build() => ReminderFilter.all;

  void setFilter(ReminderFilter filter) => state = filter;
}

final scheduleFilterProvider =
    NotifierProvider<ScheduleViewModel, ReminderFilter>(
  ScheduleViewModel.new,
);

// ---------------------------------------------------------------------------
// VaccinationRemindersViewModel
// ---------------------------------------------------------------------------

class VaccinationRemindersViewModel
    extends AsyncNotifier<List<VaccinationReminder>> {
  @override
  Future<List<VaccinationReminder>> build() async {
    final user = await ref.watch(activeUserProvider.future);
    if (user == null) return [];
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final leadTimeDays = await settingsRepo.getLeadTimeDays();
    final seriesUseCase = ref.read(getVaccinationSeriesUseCaseProvider);
    final useCase = GetVaccinationRemindersUseCase(
      seriesUseCase,
      leadTimeDays: leadTimeDays,
    );
    return useCase.call(user.id!);
  }
}

final vaccinationRemindersProvider = AsyncNotifierProvider<
    VaccinationRemindersViewModel, List<VaccinationReminder>>(
  VaccinationRemindersViewModel.new,
);

// ---------------------------------------------------------------------------
// filteredRemindersProvider – derived from filter + reminders
// ---------------------------------------------------------------------------

final filteredRemindersProvider =
    Provider<AsyncValue<List<VaccinationReminder>>>((ref) {
  final filter = ref.watch(scheduleFilterProvider);
  final remindersAsync = ref.watch(vaccinationRemindersProvider);
  return remindersAsync.whenData((reminders) {
    if (filter == ReminderFilter.all) return reminders;
    return reminders.where((r) {
      switch (filter) {
        case ReminderFilter.overdue:
          return r.status == ReminderStatus.overdue;
        case ReminderFilter.dueSoon:
          return r.status == ReminderStatus.dueSoon;
        case ReminderFilter.upToDate:
          return r.status == ReminderStatus.upToDate;
        case ReminderFilter.all:
          return true;
      }
    }).toList();
  });
});

// ---------------------------------------------------------------------------
// seriesListProvider – derived: entries → series (no extra DB call)
// ---------------------------------------------------------------------------

final seriesListProvider =
    Provider<AsyncValue<List<VaccinationSeriesEntity>>>((ref) {
  final entriesAsync = ref.watch(vaccinationProvider);
  final useCase = ref.read(getVaccinationSeriesUseCaseProvider);
  return entriesAsync.whenData((entries) => useCase.fromEntries(entries));
});
