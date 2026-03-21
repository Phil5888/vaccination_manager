import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vaccination_manager/data/models/random_user_model.dart';
import 'package:vaccination_manager/domain/entities/random_user_entity.dart';
import 'package:vaccination_manager/domain/repositories/random_user_repository.dart' as domain;

class RandomUserRepositoryImpl implements domain.RandomUserRepository {
  final http.Client client;

  RandomUserRepositoryImpl({http.Client? client}) : client = client ?? http.Client();

  @override
  Future<RandomUserEntity> fetchRandomUser() async {
    final uri = Uri.parse('https://randomuser.me/api/');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final userJson = data['results'][0] as Map<String, dynamic>;
      final userModel = RandomUser.fromJson(userJson);
      return RandomUserEntity(
        name: NameEntity(title: userModel.name.title, first: userModel.name.first, last: userModel.name.last),
        gender: userModel.gender,
        email: userModel.email,
        picture: PictureEntity(large: userModel.picture.large, medium: userModel.picture.medium, thumbnail: userModel.picture.thumbnail),
      );
    } else {
      throw Exception('Failed to load random user');
    }
  }
}
