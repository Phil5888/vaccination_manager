import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/entities/vaccination_series_entity.dart';
import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';

class GetVaccinationSeriesUseCase {
  const GetVaccinationSeriesUseCase(this._repository);
  final VaccinationRepository _repository;

  Future<List<VaccinationSeriesEntity>> call(int userId) async {
    final entries = await _repository.getVaccinationsForUser(userId);
    return fromEntries(entries, overrideUserId: userId);
  }

  /// Converts an already-fetched list of entries into series without a DB hit.
  List<VaccinationSeriesEntity> fromEntries(
    List<VaccinationEntryEntity> entries, {
    int? overrideUserId,
  }) {
    final groups = <String, List<VaccinationEntryEntity>>{};
    final nameMap = <String, String>{};
    for (final e in entries) {
      final key = e.name.toLowerCase();
      nameMap.putIfAbsent(key, () => e.name);
      groups.putIfAbsent(key, () => []).add(e);
    }
    return groups.entries.map((entry) {
      final sorted = List.of(entry.value)
        ..sort((a, b) => a.shotNumber.compareTo(b.shotNumber));
      return VaccinationSeriesEntity(
        name: nameMap[entry.key]!,
        userId: overrideUserId ?? sorted.first.userId,
        shots: sorted,
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}
