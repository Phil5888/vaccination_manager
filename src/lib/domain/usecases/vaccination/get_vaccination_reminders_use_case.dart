import 'package:vaccination_manager/domain/entities/reminder_status.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_status.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/get_vaccination_series_use_case.dart';

class VaccinationReminder {
  final VaccinationSeriesEntity series;
  final ReminderStatus status;

  const VaccinationReminder({required this.series, required this.status});
}

class GetVaccinationRemindersUseCase {
  const GetVaccinationRemindersUseCase(
    this._seriesUseCase, {
    this.leadTimeDays = 30,
  });

  final GetVaccinationSeriesUseCase _seriesUseCase;
  final int leadTimeDays;

  Future<List<VaccinationReminder>> call(int userId) async {
    final seriesList = await _seriesUseCase.call(userId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final soonLimit = today.add(Duration(days: leadTimeDays));

    final reminders = seriesList.map((series) {
      final seriesStatus = series.seriesStatus;
      final nextAction = series.nextActionDate;
      final ReminderStatus status;

      if (seriesStatus == VaccinationSeriesStatus.overdue) {
        status = ReminderStatus.overdue;
      } else if (seriesStatus == VaccinationSeriesStatus.complete) {
        status = ReminderStatus.upToDate;
      } else {
        // inProgress or planned — check nextActionDate for dueSoon
        if (nextAction != null &&
            !nextAction.isBefore(today) &&
            nextAction.isBefore(soonLimit)) {
          status = ReminderStatus.dueSoon;
        } else if (nextAction != null && nextAction.isBefore(today)) {
          // Action date already passed but series isn't complete — overdue
          status = ReminderStatus.overdue;
        } else {
          status = ReminderStatus.upToDate;
        }
      }

      return VaccinationReminder(series: series, status: status);
    }).toList();

    // Sort: overdue first, then dueSoon, then upToDate;
    // within each group sort by nextActionDate ASC (nulls last).
    reminders.sort((a, b) {
      final aOrder = _statusOrder(a.status);
      final bOrder = _statusOrder(b.status);
      if (aOrder != bOrder) return aOrder.compareTo(bOrder);
      final aDate = a.series.nextActionDate;
      final bDate = b.series.nextActionDate;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });

    return reminders;
  }

  static int _statusOrder(ReminderStatus s) {
    switch (s) {
      case ReminderStatus.overdue:
        return 0;
      case ReminderStatus.dueSoon:
        return 1;
      case ReminderStatus.upToDate:
        return 2;
    }
  }
}
