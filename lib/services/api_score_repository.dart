import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/score.dart';
import 'score_repository.dart';

/// Implémentation HTTP du [ScoreRepository].
///
/// Utilise JSONPlaceholder pour simuler une API REST.
class ApiScoreRepository implements ScoreRepository {
  static const _baseUrl =
      'https://jsonplaceholder.typicode.com';

  @override
  Future<List<Score>> fetchLeaderboard() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users'),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur réseau : ${response.statusCode}');
    }
    final List<dynamic> data =
        jsonDecode(response.body) as List<dynamic>;
    return data
        .map(
          (u) => Score(
            name: u['name'] as String,
            cookies: (u['id'] as int) * 1234,
          ),
        )
        .toList()
      ..sort((a, b) => b.cookies.compareTo(a.cookies));
  }

  @override
  Future<void> submitScore(Score score) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': score.name,
        'body': '${score.cookies} cookies',
        'userId': 1,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Envoi échoué : ${response.statusCode}');
    }
  }
}
