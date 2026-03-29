import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';

/// In-memory [VaccinationRepository] for tests.
class FakeVaccinationRepository implements VaccinationRepository {
  final List<VaccinationEntryEntity> _store = [];
  int _nextId = 1;

  /// Pre-populate the store. Entries without an id get one auto-assigned.
  void seedAll(List<VaccinationEntryEntity> entries) {
    _store.clear();
    _nextId = 1;
    for (final e in entries) {
      if (e.id != null) {
        _store.add(e);
        if (e.id! >= _nextId) _nextId = e.id! + 1;
      } else {
        _store.add(e.copyWith(id: _nextId++));
      }
    }
  }

  /// All entries currently in the store (unfiltered).
  List<VaccinationEntryEntity> get all => List.unmodifiable(_store);

  @override
  Future<List<VaccinationEntryEntity>> getVaccinationsForUser(
      int userId) async {
    return _store.where((e) => e.userId == userId).toList();
  }

  @override
  Future<VaccinationEntryEntity> saveVaccination(
      VaccinationEntryEntity entry) async {
    if (entry.id == null) {
      final saved = entry.copyWith(id: _nextId++);
      _store.add(saved);
      return saved;
    } else {
      final idx = _store.indexWhere((e) => e.id == entry.id);
      if (idx >= 0) {
        _store[idx] = entry;
      } else {
        _store.add(entry);
      }
      return entry;
    }
  }

  @override
  Future<void> deleteVaccinationShot(int id) async {
    _store.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> saveVaccinationSeries(
    List<VaccinationEntryEntity> shots, {
    String? oldName,
  }) async {
    if (shots.isEmpty) return;
    final userId = shots.first.userId;
    final deleteKey = (oldName ?? shots.first.name).toLowerCase();
    _store.removeWhere(
      (e) => e.userId == userId && e.name.toLowerCase() == deleteKey,
    );
    for (final shot in shots) {
      _store.add(shot.copyWith(id: _nextId++));
    }
  }

  @override
  Future<void> deleteVaccinationSeries(int userId, String name) async {
    _store.removeWhere(
      (e) => e.userId == userId && e.name.toLowerCase() == name.toLowerCase(),
    );
  }
}
