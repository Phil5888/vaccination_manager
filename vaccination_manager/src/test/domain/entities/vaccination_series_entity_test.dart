import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';

void main() {
  group('VaccinationSeriesEntity', () {
    test('sorts entries by newest vaccination date first', () {
      final series = VaccinationSeriesEntity(
        name: 'COVID-19',
        entries: [
          _entry(id: 1, vaccinationDate: DateTime(2025, 1, 10), nextDate: DateTime(2025, 7, 10)),
          _entry(id: 2, vaccinationDate: DateTime(2025, 3, 10), nextDate: DateTime(2025, 9, 10)),
        ],
      );

      expect(series.latestEntry.id, 2);
      expect(series.shotCount, 2);
    });

    test('marks overdue entries correctly', () {
      final series = VaccinationSeriesEntity(
        name: 'FSME',
        entries: [_entry(id: 1, vaccinationDate: DateTime(2025, 1, 10), nextDate: DateTime(2025, 2, 10))],
      );

      expect(series.statusAt(DateTime(2025, 3, 1)), VaccinationDueStatus.overdue);
    });

    test('marks soon due entries correctly', () {
      final series = VaccinationSeriesEntity(
        name: 'Influenza',
        entries: [_entry(id: 1, vaccinationDate: DateTime(2025, 1, 10), nextDate: DateTime(2025, 3, 20))],
      );

      expect(series.statusAt(DateTime(2025, 3, 1)), VaccinationDueStatus.dueSoon);
    });

    test('marks entries up to date when next date is more than 30 days away', () {
      final series = VaccinationSeriesEntity(
        name: 'Hepatitis',
        entries: [_entry(id: 1, vaccinationDate: DateTime(2025, 1, 10), nextDate: DateTime(2025, 4, 2))],
      );

      expect(series.statusAt(DateTime(2025, 3, 1)), VaccinationDueStatus.upToDate);
    });

    test('marks due soon when a planned future shot is within 30 days', () {
      final series = VaccinationSeriesEntity(
        name: 'FSME',
        entries: [
          _entry(id: 1, vaccinationDate: DateTime(2025, 2, 20), nextDate: DateTime(2025, 9, 1)),
          _entry(id: 2, vaccinationDate: DateTime(2025, 3, 20), nextDate: DateTime(2025, 9, 1)),
        ],
      );

      expect(series.nextDueDateAt(DateTime(2025, 3, 1)), DateTime(2025, 3, 20));
      expect(series.statusAt(DateTime(2025, 3, 1)), VaccinationDueStatus.dueSoon);
    });
  });
}

VaccinationEntryEntity _entry({required int id, required DateTime vaccinationDate, required DateTime nextDate}) {
  return VaccinationEntryEntity(id: id, userId: 1, name: 'Example', vaccinationDate: vaccinationDate, nextVaccinationRequiredDate: nextDate, createdAt: vaccinationDate);
}
