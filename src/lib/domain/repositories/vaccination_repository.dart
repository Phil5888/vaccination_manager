import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';

abstract class VaccinationRepository {
  Future<List<VaccinationEntryEntity>> getVaccinationsForUser(int userId);
  Future<VaccinationEntryEntity> saveVaccination(VaccinationEntryEntity entry);
  Future<void> deleteVaccinationShot(int id);

  /// Deletes all existing shots for [userId]+[oldName] (or [name] when
  /// [oldName] is null) then inserts [shots] in a single transaction.
  ///
  /// Pass [oldName] when renaming a series so that records stored under the
  /// original name are removed before the new shots are inserted.
  Future<void> saveVaccinationSeries(
    List<VaccinationEntryEntity> shots, {
    String? oldName,
  });

  /// Deletes all shots belonging to the series identified by [userId] and
  /// [name] (case-insensitive).
  Future<void> deleteVaccinationSeries(int userId, String name);
}
