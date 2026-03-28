import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';

class GetVaccinationsForUserUseCase {
  final VaccinationRepository _repository;

  const GetVaccinationsForUserUseCase(this._repository);

  Future<List<VaccinationEntryEntity>> call(int userId) {
    return _repository.getVaccinationsForUser(userId);
  }
}
