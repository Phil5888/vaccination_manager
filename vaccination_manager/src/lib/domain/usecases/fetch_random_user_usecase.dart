import 'package:vaccination_manager/domain/entities/random_user_entity.dart';
import 'package:vaccination_manager/domain/repositories/random_user_repository.dart';

class FetchRandomUserUseCase {
  final RandomUserRepository repository;

  FetchRandomUserUseCase(this.repository);

  Future<RandomUserEntity> call() {
    return repository.fetchRandomUser();
  }
}
