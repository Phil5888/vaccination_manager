import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';

class DeleteVaccinationSeriesUseCase {
  final VaccinationRepository repository;

  const DeleteVaccinationSeriesUseCase(this.repository);

  Future<void> call(int userId, String name) =>
      repository.deleteVaccinationSeries(userId, name);
}
