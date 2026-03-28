import 'package:vaccination_manager/domain/entities/user_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';

/// Static factory helpers for test data.
///
/// All dates are computed relative to today so tests stay green indefinitely.
class Fixtures {
  Fixtures._();

  static final DateTime _today = () {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }();

  static DateTime get today => _today;
  static DateTime get yesterday => _today.subtract(const Duration(days: 1));
  static DateTime get tomorrow => _today.add(const Duration(days: 1));
  static DateTime get inThirtyDays => _today.add(const Duration(days: 30));
  static DateTime get inSixtyDays => _today.add(const Duration(days: 60));
  static DateTime get thirtyDaysAgo => _today.subtract(const Duration(days: 30));

  // ---------------------------------------------------------------------------
  // Single-shot helpers
  // ---------------------------------------------------------------------------

  static VaccinationEntryEntity singleShotPast({
    String name = 'Flu',
    int userId = 1,
  }) =>
      VaccinationEntryEntity(
        userId: userId,
        name: name,
        shotNumber: 1,
        totalShots: 1,
        vaccinationDate: yesterday,
      );

  static VaccinationEntryEntity singleShotFuture({
    String name = 'Flu',
    int userId = 1,
  }) =>
      VaccinationEntryEntity(
        userId: userId,
        name: name,
        shotNumber: 1,
        totalShots: 1,
        vaccinationDate: inThirtyDays,
      );

  static VaccinationEntryEntity singleShotUnscheduled({
    String name = 'Flu',
    int userId = 1,
  }) =>
      VaccinationEntryEntity(
        userId: userId,
        name: name,
        shotNumber: 1,
        totalShots: 1,
        vaccinationDate: null,
      );

  /// Completed single shot; optionally carries a next-dose reminder date.
  static VaccinationEntryEntity singleShotComplete({
    String name = 'Flu',
    int userId = 1,
    DateTime? nextVaccinationDate,
  }) =>
      VaccinationEntryEntity(
        userId: userId,
        name: name,
        shotNumber: 1,
        totalShots: 1,
        vaccinationDate: yesterday,
        nextVaccinationDate: nextVaccinationDate,
      );

  // ---------------------------------------------------------------------------
  // Multi-shot helpers
  // ---------------------------------------------------------------------------

  /// Returns three [VaccinationEntryEntity] records for a 3-shot series.
  /// Pass [null] for any date to leave that shot unscheduled.
  static List<VaccinationEntryEntity> threeShots({
    String name = 'COVID-19',
    int userId = 1,
    DateTime? d1,
    DateTime? d2,
    DateTime? d3,
  }) =>
      [
        VaccinationEntryEntity(
          userId: userId,
          name: name,
          shotNumber: 1,
          totalShots: 3,
          vaccinationDate: d1,
        ),
        VaccinationEntryEntity(
          userId: userId,
          name: name,
          shotNumber: 2,
          totalShots: 3,
          vaccinationDate: d2,
        ),
        VaccinationEntryEntity(
          userId: userId,
          name: name,
          shotNumber: 3,
          totalShots: 3,
          vaccinationDate: d3,
        ),
      ];

  // ---------------------------------------------------------------------------
  // User helpers
  // ---------------------------------------------------------------------------

  static UserEntity userAlice() => const UserEntity(id: 1, username: 'Alice');
  static UserEntity userBob() => const UserEntity(id: 2, username: 'Bob');
}
