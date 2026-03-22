import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';

enum VaccinationDueStatus { overdue, dueSoon, upToDate }

class VaccinationSeriesEntity {
  VaccinationSeriesEntity({required this.name, required List<VaccinationEntryEntity> entries}) : entries = _sortEntries(entries);

  final String name;
  final List<VaccinationEntryEntity> entries;

  int get shotCount => entries.length;

  VaccinationEntryEntity get latestEntry => entries.first;

  DateTime get lastShotDate => latestEntry.vaccinationDate;

  DateTime get nextRequiredDate => latestEntry.nextVaccinationRequiredDate;

  DateTime nextDueDateAt(DateTime referenceDate) {
    final upcomingShot = nextPlannedShotAt(referenceDate);
    return upcomingShot ?? nextRequiredDate;
  }

  DateTime? nextPlannedShotAt(DateTime referenceDate) {
    final today = _dateOnly(referenceDate);
    final planned = entries.map((entry) => _dateOnly(entry.vaccinationDate)).where((date) => !date.isBefore(today)).toList()..sort((a, b) => a.compareTo(b));
    if (planned.isEmpty) {
      return null;
    }
    return planned.first;
  }

  VaccinationDueStatus statusAt(DateTime referenceDate) {
    final dueDate = _dateOnly(nextDueDateAt(referenceDate));
    final today = _dateOnly(referenceDate);
    if (dueDate.isBefore(today)) {
      return VaccinationDueStatus.overdue;
    }

    final dueSoonLimit = today.add(const Duration(days: 30));
    if (!dueDate.isAfter(dueSoonLimit)) {
      return VaccinationDueStatus.dueSoon;
    }

    return VaccinationDueStatus.upToDate;
  }

  static List<VaccinationEntryEntity> _sortEntries(List<VaccinationEntryEntity> entries) {
    final sorted = List<VaccinationEntryEntity>.from(entries);
    sorted.sort((a, b) => b.vaccinationDate.compareTo(a.vaccinationDate));
    return sorted;
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
