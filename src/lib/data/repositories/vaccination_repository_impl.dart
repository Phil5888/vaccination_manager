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
      orderBy: 'name ASC, shot_number ASC',
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

  @override
  Future<void> saveVaccinationSeries(
    List<VaccinationEntryEntity> shots, {
    String? oldName,
  }) async {
    if (shots.isEmpty) return;
    final db = await AppDatabase.instance.database;
    final userId = shots.first.userId;
    final name = shots.first.name;
    // When renaming, delete the records stored under the OLD name so the
    // renamed series fully replaces it.  Fall back to the new name for
    // create-new and same-name-edit cases.
    final deleteTarget = oldName ?? name;

    await db.transaction((txn) async {
      await txn.delete(
        _table,
        where: 'user_id = ? AND LOWER(name) = LOWER(?)',
        whereArgs: [userId, deleteTarget],
      );
      for (final shot in shots) {
        final model = VaccinationModel.fromEntity(shot);
        // Strip the id so each shot gets a fresh AUTOINCREMENT id
        final map = model.toMap()..remove('id');
        await txn.insert(_table, map);
      }
    });
  }

  @override
  Future<void> deleteVaccinationSeries(int userId, String name) async {
    final db = await AppDatabase.instance.database;
    await db.delete(
      _table,
      where: 'user_id = ? AND LOWER(name) = LOWER(?)',
      whereArgs: [userId, name],
    );
  }
}
