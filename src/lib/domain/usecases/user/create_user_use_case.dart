import 'package:vaccination_manager/domain/entities/user_entity.dart';
import 'package:vaccination_manager/domain/repositories/user_repository.dart';

class CreateUserUseCase {
  final UserRepository _repository;

  const CreateUserUseCase(this._repository);

  Future<UserEntity> call(UserEntity user) {
    return _repository.createUser(user);
  }
}
