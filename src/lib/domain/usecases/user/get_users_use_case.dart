import 'package:vaccination_manager/domain/entities/user_entity.dart';
import 'package:vaccination_manager/domain/repositories/user_repository.dart';

class GetUsersUseCase {
  final UserRepository _repository;

  const GetUsersUseCase(this._repository);

  Future<List<UserEntity>> call() {
    return _repository.getAllUsers();
  }
}
