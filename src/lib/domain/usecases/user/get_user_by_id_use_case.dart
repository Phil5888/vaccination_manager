import 'package:vaccination_manager/domain/entities/user_entity.dart';
import 'package:vaccination_manager/domain/repositories/user_repository.dart';

class GetUserByIdUseCase {
  final UserRepository _repository;

  const GetUserByIdUseCase(this._repository);

  Future<UserEntity?> call(int id) {
    return _repository.getUserById(id);
  }
}
