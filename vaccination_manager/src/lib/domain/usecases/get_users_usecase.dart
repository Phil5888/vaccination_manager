import 'package:vaccination_manager/domain/entities/app_user_entity.dart';
import 'package:vaccination_manager/domain/repositories/app_user_repository.dart';

class GetUsersUseCase {
  const GetUsersUseCase(this._repository);

  final AppUserRepository _repository;

  Future<List<AppUserEntity>> call() {
    return _repository.getUsers();
  }
}
