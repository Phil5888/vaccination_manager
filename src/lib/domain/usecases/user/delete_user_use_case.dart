import 'package:vaccination_manager/domain/repositories/user_repository.dart';

class DeleteUserUseCase {
  final UserRepository _repository;

  const DeleteUserUseCase(this._repository);

  Future<void> call(int id) {
    return _repository.deleteUser(id);
  }
}
