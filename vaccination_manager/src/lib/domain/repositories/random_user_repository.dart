import 'package:vaccination_manager/domain/entities/random_user_entity.dart';

abstract class RandomUserRepository {
  Future<RandomUserEntity> fetchRandomUser();
}
