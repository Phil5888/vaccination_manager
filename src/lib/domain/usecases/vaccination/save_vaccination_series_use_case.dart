import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';

class SaveVaccinationSeriesUseCase {
  final VaccinationRepository repository;

  const SaveVaccinationSeriesUseCase(this.repository);

  Future<void> call(List<VaccinationEntryEntity> shots) =>
      repository.saveVaccinationSeries(shots);
}
