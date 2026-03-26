import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reyrazak/config/app_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  static final Uri baseUri = () {
    assert(baseUrl == baseUrl.trim());
    assert(!baseUrl.contains('`'));
    final uri = Uri.parse(baseUrl);
    assert(uri.scheme == 'https');
    return uri;
  }();

  String? _accessToken;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  String? get accessToken => _accessToken;

  Map<String, String> _getHeaders() {
    return ApiConfig.authHeaders(_accessToken);
  }

  Future<Map<String, dynamic>> authenticateByName(String username, String password) async {
    final url = Uri.parse(ApiConfig.fullUrl(ApiConfig.authEndpoint));

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Emby-Authorization': ApiConfig.embyAuthHeader,
      },
      body: jsonEncode({
        'Username': username,
        'Pw': password,
      }),
    );

    print('Login Response Status: ${response.statusCode}');
    print('Login Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['AccessToken'];
      print('Token stored: $_accessToken');
      return data;
    } else {
      throw Exception('Authentication failed: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchMovies() async {
    final url = Uri.parse(ApiConfig.fullUrl(ApiConfig.moviesEndpoint));

    print('Fetching movies with token: $_accessToken');
    print('Headers: ${_getHeaders()}');

    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    print('Fetch Movies Response Status: ${response.statusCode}');
    print('Fetch Movies Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Items'] ?? [];
    } else {
      throw Exception('Failed to fetch movies: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchShows() async {
    final url = Uri.parse(ApiConfig.fullUrl(ApiConfig.seriesEndpoint));

    print('Fetching shows with token: $_accessToken');

    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    print('Fetch Shows Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Items'] ?? [];
    } else {
      throw Exception('Failed to fetch shows: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchAllContent() async {
    final url = Uri.parse(ApiConfig.fullUrl(ApiConfig.allContentEndpoint));

    print('Fetching all content with token: $_accessToken');

    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    print('Fetch All Content Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Items'] ?? [];
    } else {
      throw Exception('Failed to fetch content: ${response.body}');
    }
  }

  String getImageUrl(String itemId) {
    return ApiConfig.fullUrl(ApiConfig.primaryImageEndpoint(itemId));
  }

  String getBackdropUrl(String itemId) {
    return ApiConfig.fullUrl(ApiConfig.backdropImageEndpoint(itemId));
  }

  String getStreamUrl(String itemId) {
    // Use multiple streaming options for better compatibility
    // Try Direct Play URL which works better with Flutter video player
    return ApiConfig.fullUrl(ApiConfig.downloadEndpoint(itemId, _accessToken!));
  }

  String getDirectStreamUrl(String itemId, String? mediaSourceId) {
    // Alternative: Direct stream URL with media source
    final source = mediaSourceId ?? itemId;
    return ApiConfig.fullUrl(ApiConfig.staticStreamEndpoint(itemId, source, _accessToken!));
  }

  String getTranscodedStreamUrl(String itemId) {
    // For transcoding support (fallback)
    return ApiConfig.fullUrl(ApiConfig.hlsStreamEndpoint(itemId, _accessToken!));
  }

  Future<List<dynamic>> fetchSeasons(String seriesId) async {
    final url = Uri.parse(ApiConfig.fullUrl(ApiConfig.seasonsEndpoint(seriesId)));

    print('Fetching seasons for series: $seriesId');

    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    print('Fetch Seasons Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Items'] ?? [];
    } else {
      throw Exception('Failed to fetch seasons: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchEpisodes(String seasonId) async {
    final url = Uri.parse(ApiConfig.fullUrl(ApiConfig.episodesEndpoint(seasonId)));

    print('Fetching episodes for season: $seasonId');

    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    print('Fetch Episodes Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Items'] ?? [];
    } else {
      throw Exception('Failed to fetch episodes: ${response.body}');
    }
  }
}
