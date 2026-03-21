import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vaccination_manager/data/models/random_user_model.dart';

class RandomUserRepository {
  final http.Client client;

  RandomUserRepository({http.Client? client}) : client = client ?? http.Client();

  Future<RandomUser> fetchRandomUser() async {
    final uri = Uri.parse('https://randomuser.me/api/');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final userJson = data['results'][0] as Map<String, dynamic>;
      return RandomUser.fromJson(userJson);
    } else {
      throw Exception('Failed to load random user');
    }
  }
}
