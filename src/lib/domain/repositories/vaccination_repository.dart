import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';

abstract class VaccinationRepository {
  Future<List<VaccinationEntryEntity>> getVaccinationsForUser(int userId);
  Future<VaccinationEntryEntity> saveVaccination(VaccinationEntryEntity entry);
  Future<void> deleteVaccinationShot(int id);

  /// Deletes all existing shots for [userId]+[name] then inserts [shots] in a
  /// single transaction.
  Future<void> saveVaccinationSeries(List<VaccinationEntryEntity> shots);

  /// Deletes all shots belonging to the series identified by [userId] and
  /// [name] (case-insensitive).
  Future<void> deleteVaccinationSeries(int userId, String name);
}
