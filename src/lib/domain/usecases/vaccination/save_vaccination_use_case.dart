import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';

class SaveVaccinationUseCase {
  final VaccinationRepository _repository;

  const SaveVaccinationUseCase(this._repository);

  /// Inserts if [entry.id] is null, updates otherwise.
  Future<VaccinationEntryEntity> call(VaccinationEntryEntity entry) {
    return _repository.saveVaccination(entry);
  }
}
