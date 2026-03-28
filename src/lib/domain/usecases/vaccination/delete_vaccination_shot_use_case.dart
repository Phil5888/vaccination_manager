import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';

class DeleteVaccinationShotUseCase {
  final VaccinationRepository _repository;

  const DeleteVaccinationShotUseCase(this._repository);

  Future<void> call(int id) {
    return _repository.deleteVaccinationShot(id);
  }
}
