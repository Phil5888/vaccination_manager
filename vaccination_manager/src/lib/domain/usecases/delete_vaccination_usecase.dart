import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';

class DeleteVaccinationUseCase {
  const DeleteVaccinationUseCase(this._repository);

  final VaccinationRepository _repository;

  Future<void> call(int vaccinationId) {
    return _repository.deleteVaccination(vaccinationId);
  }
}
