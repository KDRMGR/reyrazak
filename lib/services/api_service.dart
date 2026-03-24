import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://media.aplayworld.in';

  String? _accessToken;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  String? get accessToken => _accessToken;

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (_accessToken != null) {
      headers['X-Emby-Authorization'] = 'MediaBrowser Token=$_accessToken';
    }

    return headers;
  }

  Future<Map<String, dynamic>> authenticateByName(String username, String password) async {
    final url = Uri.parse('$baseUrl/Users/AuthenticateByName');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Username': username,
        'Pw': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['AccessToken'];
      return data;
    } else {
      throw Exception('Authentication failed: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchMovies() async {
    final url = Uri.parse('$baseUrl/Items?IncludeItemTypes=Movie&Recursive=true');

    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Items'] ?? [];
    } else {
      throw Exception('Failed to fetch movies: ${response.body}');
    }
  }

  String getImageUrl(String itemId) {
    return '$baseUrl/Items/$itemId/Images/Primary';
  }

  String getStreamUrl(String itemId) {
    return '$baseUrl/Videos/$itemId/stream';
  }
}
