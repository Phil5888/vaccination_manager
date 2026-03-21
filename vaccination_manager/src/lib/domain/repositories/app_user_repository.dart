import 'package:vaccination_manager/domain/entities/app_user_entity.dart';

abstract class AppUserRepository {
  Future<List<AppUserEntity>> getUsers();
  Future<AppUserEntity> saveUser(AppUserEntity user);
  Future<void> switchActiveUser(int userId);
}
