import 'package:sqflite/sqflite.dart';
import 'package:vaccination_manager/core/database/app_database.dart';
import 'package:vaccination_manager/data/models/vaccination_model.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';

class VaccinationRepositoryImpl implements VaccinationRepository {
  VaccinationRepositoryImpl({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  @override
  Future<List<VaccinationEntryEntity>> getVaccinationsForUser(int userId) async {
    final db = await _database.database;
    final rows = await db.query('vaccinations', where: 'user_id = ?', whereArgs: [userId], orderBy: 'vaccination_date DESC, created_at DESC');
    return rows.map(VaccinationModel.fromMap).map((model) => model.toEntity()).toList();
  }

  @override
  Future<VaccinationEntryEntity> saveVaccination(VaccinationEntryEntity entry) async {
    final db = await _database.database;
    final model = VaccinationModel.fromEntity(entry.copyWith(name: entry.name.trim()));

    if (entry.id == null) {
      final id = await db.insert('vaccinations', model.toMap()..remove('id'), conflictAlgorithm: ConflictAlgorithm.replace);
      return model.toEntity().copyWith(id: id);
    }

    await db.update('vaccinations', model.toMap()..remove('id'), where: 'id = ?', whereArgs: [entry.id], conflictAlgorithm: ConflictAlgorithm.replace);

    return model.toEntity();
  }

  @override
  Future<void> deleteVaccination(int vaccinationId) async {
    final db = await _database.database;
    await db.delete('vaccinations', where: 'id = ?', whereArgs: [vaccinationId]);
  }
}
