import 'package:vaccination_manager/core/database/app_database.dart';
import 'package:vaccination_manager/data/models/user_model.dart';
import 'package:vaccination_manager/domain/entities/user_entity.dart';
import 'package:vaccination_manager/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  static const _table = 'users';

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(_table);
    return maps.map((m) => UserModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<UserEntity?> getUserById(int id) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<UserEntity> createUser(UserEntity user) async {
    final db = await AppDatabase.instance.database;
    final model = UserModel.fromEntity(user);
    final id = await db.insert(_table, model.toMap());
    return user.copyWith(id: id);
  }

  @override
  Future<UserEntity> updateUser(UserEntity user) async {
    final db = await AppDatabase.instance.database;
    final model = UserModel.fromEntity(user);
    await db.update(
      _table,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return user;
  }

  @override
  Future<void> deleteUser(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
