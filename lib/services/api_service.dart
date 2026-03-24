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
      headers: {
        'Content-Type': 'application/json',
        'X-Emby-Authorization': 'MediaBrowser Client="FlutterApp", Device="Web", DeviceId="device123", Version="1.0"',
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
    final url = Uri.parse('$baseUrl/Items?IncludeItemTypes=Movie&Recursive=true');

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
    final url = Uri.parse('$baseUrl/Items?IncludeItemTypes=Series&Recursive=true');

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
    final url = Uri.parse('$baseUrl/Items?IncludeItemTypes=Movie,Series&Recursive=true');

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
    return '$baseUrl/Items/$itemId/Images/Primary';
  }

  String getBackdropUrl(String itemId) {
    return '$baseUrl/Items/$itemId/Images/Backdrop';
  }

  String getStreamUrl(String itemId) {
    // Use multiple streaming options for better compatibility
    // Try Direct Play URL which works better with Flutter video player
    return '$baseUrl/Items/$itemId/Download?api_key=$_accessToken';
  }

  String getDirectStreamUrl(String itemId, String? mediaSourceId) {
    // Alternative: Direct stream URL with media source
    final source = mediaSourceId ?? itemId;
    return '$baseUrl/Videos/$itemId/stream?Static=true&MediaSourceId=$source&api_key=$_accessToken';
  }

  String getTranscodedStreamUrl(String itemId) {
    // For transcoding support (fallback)
    return '$baseUrl/Videos/$itemId/master.m3u8?VideoCodec=h264&AudioCodec=aac&api_key=$_accessToken';
  }

  Future<List<dynamic>> fetchSeasons(String seriesId) async {
    final url = Uri.parse('$baseUrl/Shows/$seriesId/Seasons');

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
    final url = Uri.parse('$baseUrl/Items?ParentId=$seasonId');

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
