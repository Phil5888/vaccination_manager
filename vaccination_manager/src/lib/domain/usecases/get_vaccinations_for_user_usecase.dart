import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';

class GetVaccinationsForUserUseCase {
  const GetVaccinationsForUserUseCase(this._repository);

  final VaccinationRepository _repository;

  Future<List<VaccinationEntryEntity>> call(int userId) {
    return _repository.getVaccinationsForUser(userId);
  }
}
