import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';

abstract class VaccinationRepository {
  Future<List<VaccinationEntryEntity>> getVaccinationsForUser(int userId);
  Future<VaccinationEntryEntity> saveVaccination(VaccinationEntryEntity entry);
}
