import 'package:vaccination_manager/core/database/app_database.dart';
import 'package:vaccination_manager/data/models/synced_event_model.dart';
import 'package:vaccination_manager/domain/entities/synced_event_record.dart';
import 'package:vaccination_manager/domain/repositories/synced_event_repository.dart';

class SyncedEventRepositoryImpl implements SyncedEventRepository {
  static const _table = 'calendar_sync_records';

  @override
  Future<List<SyncedEventRecord>> getForShot(int vaccinationId) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      _table,
      where: 'vaccination_id = ?',
      whereArgs: [vaccinationId],
    );
    return maps.map((m) => SyncedEventModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<List<SyncedEventRecord>> getForUser(int userId) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      _table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'synced_at DESC',
    );
    return maps.map((m) => SyncedEventModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<void> insert(SyncedEventRecord record) async {
    final db = await AppDatabase.instance.database;
    final model = SyncedEventModel.fromEntity(record);
    await db.insert(_table, model.toMap());
  }

  @override
  Future<void> deleteForShot(int vaccinationId) async {
    final db = await AppDatabase.instance.database;
    await db.delete(
      _table,
      where: 'vaccination_id = ?',
      whereArgs: [vaccinationId],
    );
  }

  @override
  Future<void> deleteAll(int userId) async {
    final db = await AppDatabase.instance.database;
    await db.delete(
      _table,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
