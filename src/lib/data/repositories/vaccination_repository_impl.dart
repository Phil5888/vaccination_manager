import 'package:vaccination_manager/core/database/app_database.dart';
import 'package:vaccination_manager/data/models/vaccination_model.dart';
import 'package:vaccination_manager/domain/entities/vaccination_entry_entity.dart';
import 'package:vaccination_manager/domain/repositories/vaccination_repository.dart';

class VaccinationRepositoryImpl implements VaccinationRepository {
  static const _table = 'vaccinations';

  @override
  Future<List<VaccinationEntryEntity>> getVaccinationsForUser(
      int userId) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      _table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'vaccination_date DESC',
    );
    return maps.map((m) => VaccinationModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<VaccinationEntryEntity> saveVaccination(
      VaccinationEntryEntity entry) async {
    final db = await AppDatabase.instance.database;
    final model = VaccinationModel.fromEntity(entry);
    if (entry.id == null) {
      final id = await db.insert(_table, model.toMap());
      return entry.copyWith(id: id);
    } else {
      await db.update(
        _table,
        model.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
      return entry;
    }
  }

  @override
  Future<void> deleteVaccinationShot(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
