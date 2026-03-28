import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';

class GetVaccinationSeriesUseCase {
  const GetVaccinationSeriesUseCase(this._repository);
  final VaccinationRepository _repository;

  Future<List<VaccinationSeriesEntity>> call(int userId) async {
    final entries = await _repository.getVaccinationsForUser(userId);
    // Group by lowercased name, preserve original casing from first-seen entry
    final groups = <String, List<VaccinationEntryEntity>>{};
    final nameMap = <String, String>{}; // lowercase → original casing
    for (final e in entries) {
      final key = e.name.toLowerCase();
      nameMap.putIfAbsent(key, () => e.name);
      groups.putIfAbsent(key, () => []).add(e);
    }
    return groups.entries.map((entry) {
      final sorted = List.of(entry.value)
        ..sort((a, b) => a.vaccinationDate.compareTo(b.vaccinationDate));
      return VaccinationSeriesEntity(
        name: nameMap[entry.key]!,
        shots: sorted,
      );
    }).toList()
      ..sort((a, b) => b.latestShot.vaccinationDate
          .compareTo(a.latestShot.vaccinationDate)); // most recent first
  }
}
