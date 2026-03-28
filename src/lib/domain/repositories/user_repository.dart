import 'package:vaccination_manager/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getAllUsers();
  Future<UserEntity?> getUserById(int id);
  Future<UserEntity> createUser(UserEntity user);
  Future<UserEntity> updateUser(UserEntity user);
  Future<void> deleteUser(int id);
}
