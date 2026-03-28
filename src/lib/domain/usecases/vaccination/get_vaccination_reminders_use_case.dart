import 'package:vaccination_manager/domain/entities/reminder_status.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
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
    final soonLimit = now.add(Duration(days: leadTimeDays));

    final reminders = seriesList.map((series) {
      final next = series.nextVaccinationDate;
      final ReminderStatus status;
      if (next != null && next.isBefore(now)) {
        status = ReminderStatus.overdue;
      } else if (next != null &&
          next.isAfter(now) &&
          next.isBefore(soonLimit)) {
        status = ReminderStatus.dueSoon;
      } else {
        status = ReminderStatus.upToDate;
      }
      return VaccinationReminder(series: series, status: status);
    }).toList();

    // Sort: overdue first, then dueSoon, then upToDate; within group by nextVaccinationDate ASC
    reminders.sort((a, b) {
      final aOrder = _statusOrder(a.status);
      final bOrder = _statusOrder(b.status);
      if (aOrder != bOrder) return aOrder.compareTo(bOrder);
      final aDate = a.series.nextVaccinationDate;
      final bDate = b.series.nextVaccinationDate;
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
