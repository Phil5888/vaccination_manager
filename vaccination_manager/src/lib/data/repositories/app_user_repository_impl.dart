import 'package:sqflite/sqflite.dart';
import 'package:vaccination_manager/core/database/app_database.dart';
import 'package:vaccination_manager/data/models/app_user_model.dart';
import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/repositories/app_user_repository.dart';

class AppUserRepositoryImpl implements AppUserRepository {
  AppUserRepositoryImpl({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  @override
  Future<List<AppUserEntity>> getUsers() async {
    final db = await _database.database;
    final rows = await db.query('users', orderBy: 'is_active DESC, created_at ASC');
    final users = rows.map(AppUserModel.fromMap).map((model) => model.toEntity()).toList();

    if (users.isEmpty) {
      return users;
    }

    final activeUser = _findActiveUser(users);
    if (activeUser != null) {
      return users;
    }

    final firstUser = users.first;
    await switchActiveUser(firstUser.id!);
    return getUsers();
  }

  @override
  Future<AppUserEntity> saveUser(AppUserEntity user) async {
    final db = await _database.database;
    final existingUsers = await getUsers();
    final shouldBeActive = existingUsers.isEmpty ? true : user.isActive;
    final model = AppUserModel.fromEntity(user.copyWith(isActive: shouldBeActive));

    if (user.id == null) {
      final id = await db.insert('users', model.toMap()..remove('id'), conflictAlgorithm: ConflictAlgorithm.replace);

      if (shouldBeActive) {
        await switchActiveUser(id);
      }

      return model.toEntity().copyWith(id: id, isActive: shouldBeActive);
    }

    await db.update('users', model.toMap()..remove('id'), where: 'id = ?', whereArgs: [user.id], conflictAlgorithm: ConflictAlgorithm.replace);

    if (shouldBeActive) {
      await switchActiveUser(user.id!);
    }

    return model.toEntity();
  }

  @override
  Future<void> switchActiveUser(int userId) async {
    final db = await _database.database;

    await db.transaction((txn) async {
      await txn.update('users', {'is_active': 0});
      await txn.update('users', {'is_active': 1}, where: 'id = ?', whereArgs: [userId]);
    });
  }

  AppUserEntity? _findActiveUser(List<AppUserEntity> users) {
    for (final user in users) {
      if (user.isActive) {
        return user;
      }
    }
    return null;
  }
}
