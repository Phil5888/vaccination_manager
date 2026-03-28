import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_status.dart';

import '../../helpers/fixtures.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

VaccinationSeriesEntity _series(
  List<VaccinationEntryEntity> shots, {
  String name = 'Test',
  int userId = 1,
}) =>
    VaccinationSeriesEntity(name: name, userId: userId, shots: shots);

VaccinationEntryEntity _shot({
  int shotNumber = 1,
  int totalShots = 1,
  DateTime? vaccinationDate,
  DateTime? nextVaccinationDate,
  int userId = 1,
}) =>
    VaccinationEntryEntity(
      userId: userId,
      name: 'Test',
      shotNumber: shotNumber,
      totalShots: totalShots,
      vaccinationDate: vaccinationDate,
      nextVaccinationDate: nextVaccinationDate,
    );

void main() {
  // ── completedShots ──────────────────────────────────────────────────────────
  group('completedShots', () {
    test('past date counts as completed', () {
      final s = _series([_shot(vaccinationDate: Fixtures.yesterday)]);
      expect(s.completedShots, 1);
    });

    test('today boundary counts as completed', () {
      final s = _series([_shot(vaccinationDate: Fixtures.today)]);
      expect(s.completedShots, 1);
    });

    test('future date does not count as completed', () {
      final s = _series([_shot(vaccinationDate: Fixtures.tomorrow)]);
      expect(s.completedShots, 0);
    });

    test('null date does not count as completed', () {
      final s = _series([_shot(vaccinationDate: null)]);
      expect(s.completedShots, 0);
    });

    test('2 of 3 past dates returns 2', () {
      final s = _series([
        _shot(shotNumber: 1, totalShots: 3, vaccinationDate: Fixtures.thirtyDaysAgo),
        _shot(shotNumber: 2, totalShots: 3, vaccinationDate: Fixtures.yesterday),
        _shot(shotNumber: 3, totalShots: 3, vaccinationDate: Fixtures.inThirtyDays),
      ]);
      expect(s.completedShots, 2);
    });
  });

  // ── progressPercentage ─────────────────────────────────────────────────────
  group('progressPercentage', () {
    test('2 of 3 completed is 2/3', () {
      final s = _series([
        _shot(shotNumber: 1, totalShots: 3, vaccinationDate: Fixtures.yesterday),
        _shot(shotNumber: 2, totalShots: 3, vaccinationDate: Fixtures.yesterday),
        _shot(shotNumber: 3, totalShots: 3, vaccinationDate: null),
      ]);
      expect(s.progressPercentage, closeTo(2.0 / 3.0, 1e-10));
    });

    test('0 of 1 completed is 0.0', () {
      final s = _series([_shot(vaccinationDate: null)]);
      expect(s.progressPercentage, 0.0);
    });

    test('empty shots list returns 0.0 without throwing', () {
      final s = _series([]);
      expect(s.progressPercentage, 0.0);
    });
  });

  // ── isComplete ─────────────────────────────────────────────────────────────
  group('isComplete', () {
    test('all shots with past dates returns true', () {
      final s = _series([
        _shot(shotNumber: 1, totalShots: 2, vaccinationDate: Fixtures.thirtyDaysAgo),
        _shot(shotNumber: 2, totalShots: 2, vaccinationDate: Fixtures.yesterday),
      ]);
      expect(s.isComplete, isTrue);
    });

    test('one future shot remaining returns false', () {
      final s = _series([
        _shot(shotNumber: 1, totalShots: 2, vaccinationDate: Fixtures.yesterday),
        _shot(shotNumber: 2, totalShots: 2, vaccinationDate: Fixtures.tomorrow),
      ]);
      expect(s.isComplete, isFalse);
    });

    test('all null shots returns false', () {
      final s = _series([
        _shot(shotNumber: 1, totalShots: 2, vaccinationDate: null),
        _shot(shotNumber: 2, totalShots: 2, vaccinationDate: null),
      ]);
      expect(s.isComplete, isFalse);
    });

    test('empty shots list returns false', () {
      expect(_series([]).isComplete, isFalse);
    });
  });

  // ── nextActionDate ──────────────────────────────────────────────────────────
  group('nextActionDate', () {
    test('first null-date shot returns null immediately', () {
      final s = _series([
        _shot(shotNumber: 1, totalShots: 2, vaccinationDate: null),
        _shot(shotNumber: 2, totalShots: 2, vaccinationDate: Fixtures.inThirtyDays),
      ]);
      expect(s.nextActionDate, isNull);
    });

    test('all past dates returns null', () {
      final s = _series([
        _shot(shotNumber: 1, totalShots: 2, vaccinationDate: Fixtures.thirtyDaysAgo),
        _shot(shotNumber: 2, totalShots: 2, vaccinationDate: Fixtures.yesterday),
      ]);
      expect(s.nextActionDate, isNull);
    });

    test('future shot returns its date', () {
      final s = _series([
        _shot(shotNumber: 1, totalShots: 2, vaccinationDate: Fixtures.yesterday),
        _shot(
            shotNumber: 2,
            totalShots: 2,
            vaccinationDate: Fixtures.inThirtyDays),
      ]);
      expect(s.nextActionDate, Fixtures.inThirtyDays);
    });

    test('multiple future shots returns the earliest (lowest shotNumber)', () {
      final s = _series([
        _shot(shotNumber: 1, totalShots: 3, vaccinationDate: Fixtures.tomorrow),
        _shot(
            shotNumber: 2,
            totalShots: 3,
            vaccinationDate: Fixtures.inThirtyDays),
        _shot(
            shotNumber: 3,
            totalShots: 3,
            vaccinationDate: Fixtures.inSixtyDays),
      ]);
      expect(s.nextActionDate, Fixtures.tomorrow);
    });
  });

  // ── seriesStatus ────────────────────────────────────────────────────────────
  group('seriesStatus', () {
    test('all completed, no nextVaccinationDate → complete', () {
      final s = _series([_shot(vaccinationDate: Fixtures.yesterday)]);
      expect(s.seriesStatus, VaccinationSeriesStatus.complete);
    });

    test(
        'single-shot complete, nextVaccinationDate in past → overdue', () {
      final s = _series([
        _shot(
          vaccinationDate: Fixtures.yesterday,
          nextVaccinationDate: Fixtures.thirtyDaysAgo,
        ),
      ]);
      expect(s.seriesStatus, VaccinationSeriesStatus.overdue);
    });

    test(
        'single-shot complete, nextVaccinationDate in future → complete', () {
      final s = _series([
        _shot(
          vaccinationDate: Fixtures.yesterday,
          nextVaccinationDate: Fixtures.inThirtyDays,
        ),
      ]);
      expect(s.seriesStatus, VaccinationSeriesStatus.complete);
    });

    test('multi-shot all complete, no nextVaccinationDate → complete', () {
      final s = _series([
        _shot(
            shotNumber: 1,
            totalShots: 2,
            vaccinationDate: Fixtures.thirtyDaysAgo),
        _shot(
            shotNumber: 2,
            totalShots: 2,
            vaccinationDate: Fixtures.yesterday),
      ]);
      expect(s.seriesStatus, VaccinationSeriesStatus.complete);
    });

    test('0 completed, has future dates → planned', () {
      final s = _series([
        _shot(
            shotNumber: 1,
            totalShots: 2,
            vaccinationDate: Fixtures.tomorrow),
        _shot(
            shotNumber: 2,
            totalShots: 2,
            vaccinationDate: Fixtures.inThirtyDays),
      ]);
      expect(s.seriesStatus, VaccinationSeriesStatus.planned);
    });

    test('0 completed, all null dates → planned', () {
      final s = _series([
        _shot(shotNumber: 1, totalShots: 2, vaccinationDate: null),
        _shot(shotNumber: 2, totalShots: 2, vaccinationDate: null),
      ]);
      expect(s.seriesStatus, VaccinationSeriesStatus.planned);
    });

    test('1 completed, future shots remain → inProgress', () {
      final s = _series([
        _shot(
            shotNumber: 1,
            totalShots: 3,
            vaccinationDate: Fixtures.yesterday),
        _shot(
            shotNumber: 2,
            totalShots: 3,
            vaccinationDate: Fixtures.tomorrow),
        _shot(
            shotNumber: 3,
            totalShots: 3,
            vaccinationDate: Fixtures.inThirtyDays),
      ]);
      expect(s.seriesStatus, VaccinationSeriesStatus.inProgress);
    });

    test('1 completed, null shots remain → inProgress', () {
      final s = _series([
        _shot(
            shotNumber: 1,
            totalShots: 3,
            vaccinationDate: Fixtures.yesterday),
        _shot(shotNumber: 2, totalShots: 3, vaccinationDate: null),
        _shot(shotNumber: 3, totalShots: 3, vaccinationDate: null),
      ]);
      expect(s.seriesStatus, VaccinationSeriesStatus.inProgress);
    });
  });
}
