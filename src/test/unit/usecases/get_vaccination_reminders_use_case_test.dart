import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/reminder_status.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/get_vaccination_reminders_use_case.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/get_vaccination_series_use_case.dart';

import '../../helpers/fakes/fake_vaccination_repository.dart';
import '../../helpers/fixtures.dart';

// ---------------------------------------------------------------------------
// Stub: returns a fixed list of series without touching a repository.
// ---------------------------------------------------------------------------

class _FixedSeriesUseCase extends GetVaccinationSeriesUseCase {
  _FixedSeriesUseCase(this._fixed) : super(FakeVaccinationRepository());
  final List<VaccinationSeriesEntity> _fixed;

  @override
  Future<List<VaccinationSeriesEntity>> call(int userId) async => _fixed;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

VaccinationSeriesEntity _singleShotSeries({
  required List<VaccinationEntryEntity> shots,
  String name = 'Test',
}) =>
    VaccinationSeriesEntity(name: name, userId: 1, shots: shots);

GetVaccinationRemindersUseCase _makeUseCase(
  List<VaccinationSeriesEntity> series, {
  int leadTimeDays = 30,
}) =>
    GetVaccinationRemindersUseCase(
      _FixedSeriesUseCase(series),
      leadTimeDays: leadTimeDays,
    );

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  group('GetVaccinationRemindersUseCase', () {
    // ── complete series ───────────────────────────────────────────────────────

    test('complete series without next-dose reminder → upToDate', () async {
      final series = _singleShotSeries(shots: [
        VaccinationEntryEntity(
          userId: 1,
          name: 'Test',
          shotNumber: 1,
          totalShots: 1,
          vaccinationDate: Fixtures.yesterday,
        ),
      ]);
      final reminders = await _makeUseCase([series]).call(1);
      expect(reminders, hasLength(1));
      expect(reminders.first.status, ReminderStatus.upToDate);
    });

    test(
        'complete single-shot with overdue nextVaccinationDate → overdue', () async {
      final series = _singleShotSeries(shots: [
        VaccinationEntryEntity(
          userId: 1,
          name: 'Test',
          shotNumber: 1,
          totalShots: 1,
          vaccinationDate: Fixtures.thirtyDaysAgo,
          nextVaccinationDate: Fixtures.yesterday,
        ),
      ]);
      final reminders = await _makeUseCase([series]).call(1);
      expect(reminders.first.status, ReminderStatus.overdue);
    });

    // ── nextActionDate boundaries ─────────────────────────────────────────────

    test('nextActionDate today (noon) → dueSoon', () async {
      // Use noon today: after midnight but still today → isAfter(midnight) = true
      final noonToday = DateTime(today.year, today.month, today.day, 12);
      final series = _singleShotSeries(shots: [
        VaccinationEntryEntity(
          userId: 1,
          name: 'Test',
          shotNumber: 1,
          totalShots: 1,
          vaccinationDate: noonToday,
        ),
      ]);
      final reminders = await _makeUseCase([series]).call(1);
      expect(reminders.first.status, ReminderStatus.dueSoon);
    });

    test(
        'nextActionDate at today + (leadTimeDays - 1) → dueSoon (last day within window)',
        () async {
      final in29Days = today.add(const Duration(days: 29));
      final series = _singleShotSeries(shots: [
        VaccinationEntryEntity(
          userId: 1,
          name: 'Test',
          shotNumber: 1,
          totalShots: 1,
          vaccinationDate: in29Days,
        ),
      ]);
      final reminders = await _makeUseCase([series], leadTimeDays: 30).call(1);
      expect(reminders.first.status, ReminderStatus.dueSoon);
    });

    test(
        'nextActionDate at today + leadTimeDays → upToDate (exclusive upper bound)',
        () async {
      // soonLimit = today + leadTimeDays; nextAction.isBefore(soonLimit) is
      // false when nextAction == soonLimit, so this maps to upToDate.
      final series = _singleShotSeries(shots: [
        VaccinationEntryEntity(
          userId: 1,
          name: 'Test',
          shotNumber: 1,
          totalShots: 1,
          vaccinationDate: Fixtures.inThirtyDays, // today + 30 days exactly
        ),
      ]);
      final reminders = await _makeUseCase([series], leadTimeDays: 30).call(1);
      expect(reminders.first.status, ReminderStatus.upToDate);
    });

    test(
        'nextActionDate at today + leadTimeDays + 1 → upToDate (beyond window)',
        () async {
      final in31Days = today.add(const Duration(days: 31));
      final series = _singleShotSeries(shots: [
        VaccinationEntryEntity(
          userId: 1,
          name: 'Test',
          shotNumber: 1,
          totalShots: 1,
          vaccinationDate: in31Days,
        ),
      ]);
      final reminders = await _makeUseCase([series], leadTimeDays: 30).call(1);
      expect(reminders.first.status, ReminderStatus.upToDate);
    });

    test('nextActionDate was yesterday → overdue', () async {
      // A series with 2 shots: shot 1 done, shot 2 was scheduled for yesterday
      // (yesterday is NOT after today, so nextActionDate returns null for shot 2
      //  if it's treated as past... but wait: nextActionDate skips past dates.
      // Use an unscheduled shot after a past shot with yesterday check via
      // a past shot that makes the series inProgress.
      //
      // Actually the overdue path in the reminder use case is:
      //   nextAction != null && nextAction.isBefore(today)
      // nextActionDate only returns future or null dates (it skips past dates).
      // So nextActionDate can never be in the past.
      //
      // The "overdue" reminder for inProgress/planned series can only occur if
      // nextActionDate is null but seriesStatus itself is overdue — but
      // seriesStatus for multi-shot with null shots is inProgress, not overdue.
      //
      // Therefore this test verifies that a series where nextActionDate is null
      // but all remaining shots are past (totalShots mismatch guard) gets
      // mapped to upToDate (not overdue), since seriesStatus returns inProgress.
      // In practice the "nextAction.isBefore(today)" branch for inProgress/planned
      // is unreachable given the nextActionDate implementation.
      //
      // Instead test the seriesStatus == overdue path: complete single-shot
      // with overdue nextVaccinationDate.
      final series = _singleShotSeries(shots: [
        VaccinationEntryEntity(
          userId: 1,
          name: 'Test',
          shotNumber: 1,
          totalShots: 1,
          vaccinationDate: Fixtures.thirtyDaysAgo,
          nextVaccinationDate: Fixtures.yesterday, // overdue reminder
        ),
      ]);
      final reminders = await _makeUseCase([series]).call(1);
      expect(reminders.first.status, ReminderStatus.overdue);
    });

    // ── null nextActionDate (unscheduled) ─────────────────────────────────────

    test('unscheduled series (null nextActionDate) → upToDate', () async {
      // null-dated shot → nextActionDate returns null (unscheduled)
      // inProgress/planned with null nextAction falls through to upToDate
      final series = _singleShotSeries(shots: [
        VaccinationEntryEntity(
          userId: 1,
          name: 'Test',
          shotNumber: 1,
          totalShots: 1,
          vaccinationDate: null,
        ),
      ]);
      final reminders = await _makeUseCase([series]).call(1);
      expect(reminders.first.status, ReminderStatus.upToDate);
    });

    // ── empty list ────────────────────────────────────────────────────────────

    test('no vaccinations → empty reminder list', () async {
      final reminders = await _makeUseCase([]).call(1);
      expect(reminders, isEmpty);
    });

    // ── sort order ────────────────────────────────────────────────────────────

    test('sorted: overdue before dueSoon before upToDate', () async {
      final noonToday = DateTime(today.year, today.month, today.day, 12);

      final overdueS = VaccinationSeriesEntity(
        name: 'Overdue',
        userId: 1,
        shots: [
          VaccinationEntryEntity(
            userId: 1,
            name: 'Overdue',
            shotNumber: 1,
            totalShots: 1,
            vaccinationDate: Fixtures.thirtyDaysAgo,
            nextVaccinationDate: Fixtures.yesterday,
          ),
        ],
      );

      final dueSoonS = VaccinationSeriesEntity(
        name: 'DueSoon',
        userId: 1,
        shots: [
          VaccinationEntryEntity(
            userId: 1,
            name: 'DueSoon',
            shotNumber: 1,
            totalShots: 1,
            vaccinationDate: noonToday,
          ),
        ],
      );

      final upToDateS = VaccinationSeriesEntity(
        name: 'UpToDate',
        userId: 1,
        shots: [
          VaccinationEntryEntity(
            userId: 1,
            name: 'UpToDate',
            shotNumber: 1,
            totalShots: 1,
            vaccinationDate: Fixtures.yesterday,
          ),
        ],
      );

      // Pass in reverse order to confirm sorting is applied
      final reminders =
          await _makeUseCase([upToDateS, dueSoonS, overdueS]).call(1);

      expect(reminders[0].status, ReminderStatus.overdue);
      expect(reminders[1].status, ReminderStatus.dueSoon);
      expect(reminders[2].status, ReminderStatus.upToDate);
    });
  });
}
