import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';

class FakeVaccinationRepository implements VaccinationRepository {
  FakeVaccinationRepository({List<VaccinationEntryEntity>? seedEntries}) : _entries = List<VaccinationEntryEntity>.from(seedEntries ?? const []);

  final List<VaccinationEntryEntity> _entries;
  VaccinationEntryEntity? lastSavedEntry;

  @override
  Future<List<VaccinationEntryEntity>> getVaccinationsForUser(int userId) async {
    return _entries.where((entry) => entry.userId == userId).toList();
  }

  @override
  Future<VaccinationEntryEntity> saveVaccination(VaccinationEntryEntity entry) async {
    final normalized = entry.copyWith(name: entry.name.trim());
    lastSavedEntry = normalized;

    if (normalized.id == null) {
      final nextId = _entries.isEmpty ? 1 : (_entries.map((item) => item.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
      final created = normalized.copyWith(id: nextId);
      _entries.add(created);
      return created;
    }

    final index = _entries.indexWhere((item) => item.id == normalized.id);
    if (index == -1) {
      throw StateError('Cannot update vaccination ${normalized.id}.');
    }

    _entries[index] = normalized;
    return normalized;
  }
}
