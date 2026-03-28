import 'package:flutter_test/flutter_test.dart';
import 'package:vaccination_manager/domain/entities/reminder_status.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/get_vaccination_reminders_use_case.dart';
import 'package:vaccination_manager/domain/usecases/vaccination/get_vaccination_series_use_case.dart';

import '../helpers/fakes/fake_vaccination_repository.dart';
import '../helpers/fixtures.dart';

// ---------------------------------------------------------------------------
// Stub: injects pre-built series, bypassing the repository entirely.
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

GetVaccinationRemindersUseCase _makeUseCase(
  List<VaccinationSeriesEntity> series, {
  int leadTimeDays = 30,
}) =>
    GetVaccinationRemindersUseCase(
      _FixedSeriesUseCase(series),
      leadTimeDays: leadTimeDays,
    );

VaccinationSeriesEntity _series(
  List<VaccinationEntryEntity> shots, {
  String name = 'Test',
}) =>
    VaccinationSeriesEntity(name: name, userId: 1, shots: shots);

VaccinationEntryEntity _shot({
  int shotNumber = 1,
  int totalShots = 1,
  DateTime? vaccinationDate,
  DateTime? nextVaccinationDate,
}) =>
    VaccinationEntryEntity(
      userId: 1,
      name: 'Test',
      shotNumber: shotNumber,
      totalShots: totalShots,
      vaccinationDate: vaccinationDate,
      nextVaccinationDate: nextVaccinationDate,
    );

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  group('reminder_computation', () {
    // ── due today (noon) ──────────────────────────────────────────────────────
    test('due exactly today (noon) → dueSoon', () async {
      // Noon today is after midnight-today → nextActionDate returns it.
      // !noon.isBefore(today) = true; noon.isBefore(today + 30 days) = true.
      final noonToday = DateTime(today.year, today.month, today.day, 12);
      final s = _series([_shot(vaccinationDate: noonToday)]);

      final reminders = await _makeUseCase([s]).call(1);
      expect(reminders.first.status, ReminderStatus.dueSoon);
    });

    // ── upper boundary: today + leadTimeDays is EXCLUSIVE ────────────────────
    test('due at today + leadTimeDays → upToDate (exclusive upper bound)',
        () async {
      // soonLimit = today + 30 days; nextAction.isBefore(soonLimit) is false
      // when they are equal → upToDate.
      final in30Days = today.add(const Duration(days: 30));
      final s = _series([_shot(vaccinationDate: in30Days)]);

      final reminders = await _makeUseCase([s], leadTimeDays: 30).call(1);
      expect(reminders.first.status, ReminderStatus.upToDate);
    });

    test('due at today + leadTimeDays + 1 → upToDate (beyond window)',
        () async {
      final in31Days = today.add(const Duration(days: 31));
      final s = _series([_shot(vaccinationDate: in31Days)]);

      final reminders = await _makeUseCase([s], leadTimeDays: 30).call(1);
      expect(reminders.first.status, ReminderStatus.upToDate);
    });

    // ── last day within window ────────────────────────────────────────────────
    test('due at today + (leadTimeDays - 1) → dueSoon (last day in window)',
        () async {
      final in29Days = today.add(const Duration(days: 29));
      final s = _series([_shot(vaccinationDate: in29Days)]);

      final reminders = await _makeUseCase([s], leadTimeDays: 30).call(1);
      expect(reminders.first.status, ReminderStatus.dueSoon);
    });

    // ── unscheduled / null nextActionDate ─────────────────────────────────────
    test('nextActionDate is null (unscheduled shot) → upToDate', () async {
      // null-date shot → nextActionDate returns null;
      // inProgress/planned branch: nextAction == null → falls through to upToDate.
      final s = _series([_shot(vaccinationDate: null)]);

      final reminders = await _makeUseCase([s]).call(1);
      expect(reminders.first.status, ReminderStatus.upToDate);
    });

    // ── overdue via seriesStatus ──────────────────────────────────────────────
    test('nextActionDate was yesterday (via past nextVaccinationDate) → overdue',
        () async {
      // seriesStatus == overdue when single-shot is complete and
      // nextVaccinationDate has passed.
      final s = _series([
        _shot(
          vaccinationDate: Fixtures.thirtyDaysAgo,
          nextVaccinationDate: Fixtures.yesterday,
        ),
      ]);

      final reminders = await _makeUseCase([s]).call(1);
      expect(reminders.first.status, ReminderStatus.overdue);
    });

    // ── complete series with overdue nextVaccinationDate ─────────────────────
    test('complete series with overdue nextVaccinationDate → overdue',
        () async {
      final s = VaccinationSeriesEntity(
        name: 'Flu',
        userId: 1,
        shots: [
          VaccinationEntryEntity(
            userId: 1,
            name: 'Flu',
            shotNumber: 1,
            totalShots: 1,
            vaccinationDate: Fixtures.thirtyDaysAgo,
            nextVaccinationDate: Fixtures.yesterday, // overdue reminder
          ),
        ],
      );

      final reminders = await _makeUseCase([s]).call(1);
      expect(reminders.first.status, ReminderStatus.overdue);
    });

    // ── mixed statuses → sorted overdue, dueSoon, upToDate ───────────────────
    test('mixed statuses → sorted overdue, dueSoon, upToDate', () async {
      final noonToday = DateTime(today.year, today.month, today.day, 12);

      final overdueS = VaccinationSeriesEntity(
        name: 'C',
        userId: 1,
        shots: [
          VaccinationEntryEntity(
            userId: 1,
            name: 'C',
            shotNumber: 1,
            totalShots: 1,
            vaccinationDate: Fixtures.thirtyDaysAgo,
            nextVaccinationDate: Fixtures.yesterday,
          ),
        ],
      );

      final dueSoonS = VaccinationSeriesEntity(
        name: 'B',
        userId: 1,
        shots: [
          VaccinationEntryEntity(
            userId: 1,
            name: 'B',
            shotNumber: 1,
            totalShots: 1,
            vaccinationDate: noonToday,
          ),
        ],
      );

      final upToDateS = VaccinationSeriesEntity(
        name: 'A',
        userId: 1,
        shots: [
          VaccinationEntryEntity(
            userId: 1,
            name: 'A',
            shotNumber: 1,
            totalShots: 1,
            vaccinationDate: Fixtures.yesterday,
          ),
        ],
      );

      // Pass in alphabetical (upToDate, dueSoon, overdue) order to confirm
      // sort is applied independently of input order.
      final reminders =
          await _makeUseCase([upToDateS, dueSoonS, overdueS]).call(1);

      expect(reminders, hasLength(3));
      expect(reminders[0].status, ReminderStatus.overdue);
      expect(reminders[1].status, ReminderStatus.dueSoon);
      expect(reminders[2].status, ReminderStatus.upToDate);
    });
  });
}
