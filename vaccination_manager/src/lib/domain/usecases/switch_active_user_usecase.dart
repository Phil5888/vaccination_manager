import 'package:vaccination_manager/domain/repositories/app_user_repository.dart';

class SwitchActiveUserUseCase {
  const SwitchActiveUserUseCase(this._repository);

  final AppUserRepository _repository;

  Future<void> call(int userId) {
    return _repository.switchActiveUser(userId);
  }
}
