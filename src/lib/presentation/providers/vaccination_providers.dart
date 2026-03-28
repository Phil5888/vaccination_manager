import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaccination_manager/domain/entities/reminder_status.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/get_vaccination_reminders_use_case.dart';
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

  Future<void> saveSeries(List<VaccinationEntryEntity> shots) async {
    final useCase = ref.read(saveVaccinationSeriesUseCaseProvider);
    await useCase.call(shots);
    ref.invalidateSelf();
    ref.invalidate(vaccinationRemindersProvider);
  }

  Future<void> deleteShot(int id) async {
    final useCase = ref.read(deleteVaccinationShotUseCaseProvider);
    await useCase.call(id);
    ref.invalidateSelf();
    ref.invalidate(vaccinationRemindersProvider);
  }

  Future<void> deleteSeries(int userId, String name) async {
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
