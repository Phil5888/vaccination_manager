import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';

class SaveVaccinationUseCase {
  const SaveVaccinationUseCase(this._repository);

  final VaccinationRepository _repository;

  Future<VaccinationEntryEntity> call(VaccinationEntryEntity entry) {
    return _repository.saveVaccination(entry);
  }
}
