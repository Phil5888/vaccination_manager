import 'package:vaccination_manager/data/models/random_user_model.dart';
import 'package:vaccination_manager/data/repositories/random_user_repository.dart';

class FetchRandomUserUseCase {
  final RandomUserRepository repository;

  FetchRandomUserUseCase(this.repository);

  Future<RandomUser> call() {
    return repository.fetchRandomUser();
  }
}
