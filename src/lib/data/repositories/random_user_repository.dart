import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vaccination_manager/data/models/random_user_model.dart';

class RandomUserRepository {
  final http.Client client;

  RandomUserRepository({http.Client? client}) : client = client ?? http.Client();

  Future<RandomUser> fetchRandomUser() async {
    final uri = Uri.parse('https://randomuser.me/api/');
    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to load random user: HTTP ${response.statusCode}');
      }

      final data = json.decode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response format: root is not a JSON object');
      }

      final results = data['results'];
      if (results is! List || results.isEmpty || results.first is! Map<String, dynamic>) {
        throw const FormatException('Unexpected response format: missing or invalid results list');
      }

      return RandomUser.fromJson(results.first as Map<String, dynamic>);
    } on FormatException catch (e) {
      throw Exception('Failed to parse random user response: ${e.message}');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Failed to load random user: $e');
    }
  }
}
