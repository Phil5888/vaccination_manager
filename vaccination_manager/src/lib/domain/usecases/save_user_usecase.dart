import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/repositories/app_user_repository.dart';

class SaveUserUseCase {
  const SaveUserUseCase(this._repository);

  final AppUserRepository _repository;

  Future<AppUserEntity> call(AppUserEntity user) {
    return _repository.saveUser(user);
  }
}
