import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
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
    // Validate access token is available
    if (_accessToken == null || _accessToken!.isEmpty) {
      throw Exception('Access token not available. Please login again.');
    }

    // iOS requires H.264 codec, so use HLS transcoding for better compatibility
    // This prevents OSStatus error -12847 (media format not supported)
    if (!kIsWeb) {
      try {
        if (Platform.isIOS) {
          print('iOS detected: Using HLS transcoded stream for item $itemId');
          return getTranscodedStreamUrl(itemId);
        }
      } catch (e) {
        // Platform check failed, fall through to default
      }
    }

    // For Android and Web, try direct download first (better quality/performance)
    // The player will automatically fallback to transcoding if needed
    return ApiConfig.fullUrl(ApiConfig.downloadEndpoint(itemId, _accessToken!));
  }

  String getDirectStreamUrl(String itemId, String? mediaSourceId) {
    // Validate access token is available
    if (_accessToken == null || _accessToken!.isEmpty) {
      throw Exception('Access token not available. Please login again.');
    }

    // Alternative: Direct stream URL with media source
    final source = mediaSourceId ?? itemId;
    return ApiConfig.fullUrl(ApiConfig.staticStreamEndpoint(itemId, source, _accessToken!));
  }

  String getTranscodedStreamUrl(String itemId) {
    // Validate access token is available
    if (_accessToken == null || _accessToken!.isEmpty) {
      throw Exception('Access token not available. Please login again.');
    }

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

  /// Fetch content by type (Movie, Series, MusicVideo, etc.)
  Future<List<dynamic>> fetchContentByType(String type) async {
    final endpoint = '/Items?IncludeItemTypes=$type&Recursive=true';
    final url = Uri.parse(ApiConfig.fullUrl(endpoint));

    print('Fetching $type content with token: $_accessToken');

    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    print('Fetch $type Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Items'] ?? [];
    } else {
      throw Exception('Failed to fetch $type: ${response.body}');
    }
  }

  /// Fetch music videos
  Future<List<dynamic>> fetchMusicVideos() async {
    return fetchContentByType('MusicVideo');
  }

  /// Fetch collections/box sets
  Future<List<dynamic>> fetchCollections() async {
    final endpoint = '/Items?IncludeItemTypes=BoxSet&Recursive=true';
    final url = Uri.parse(ApiConfig.fullUrl(endpoint));

    print('Fetching collections with token: $_accessToken');

    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    print('Fetch Collections Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Items'] ?? [];
    } else {
      throw Exception('Failed to fetch collections: ${response.body}');
    }
  }

  /// Fetch items in a collection
  Future<List<dynamic>> fetchCollectionItems(String collectionId) async {
    final endpoint = '/Items?ParentId=$collectionId&Recursive=false';
    final url = Uri.parse(ApiConfig.fullUrl(endpoint));

    print('Fetching items for collection: $collectionId');

    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    print('Fetch Collection Items Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Items'] ?? [];
    } else {
      throw Exception('Failed to fetch collection items: ${response.body}');
    }
  }

  /// Fetch resume (continue watching) items
  Future<List<dynamic>> fetchResumeItems() async {
    final endpoint = '/Items/Resume?Recursive=true&MediaTypes=Video';
    final url = Uri.parse(ApiConfig.fullUrl(endpoint));

    print('Fetching resume items with token: $_accessToken');

    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    print('Fetch Resume Items Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Items'] ?? [];
    } else {
      throw Exception('Failed to fetch resume items: ${response.body}');
    }
  }

  /// Fetch latest (recently added) items
  Future<List<dynamic>> fetchLatestItems({String? includeItemTypes, int limit = 20}) async {
    final types = includeItemTypes ?? 'Movie,Series,MusicVideo';
    final endpoint = '/Users/$_accessToken/Items/Latest?IncludeItemTypes=$types&Limit=$limit';
    final url = Uri.parse(ApiConfig.fullUrl(endpoint));

    print('Fetching latest items with token: $_accessToken');

    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    print('Fetch Latest Items Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Latest endpoint returns array directly, not wrapped in Items
      return data is List ? data : [];
    } else {
      throw Exception('Failed to fetch latest items: ${response.body}');
    }
  }

  /// Fetch items by genre
  Future<List<dynamic>> fetchItemsByGenre(String genre, {String? itemTypes}) async {
    final types = itemTypes ?? 'Movie,Series,MusicVideo';
    final endpoint = '/Items?IncludeItemTypes=$types&Genres=$genre&Recursive=true';
    final url = Uri.parse(ApiConfig.fullUrl(endpoint));

    print('Fetching items for genre: $genre');

    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    print('Fetch Genre Items Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['Items'] ?? [];
    } else {
      throw Exception('Failed to fetch genre items: ${response.body}');
    }
  }

  /// Fetch all genres
  Future<List<String>> fetchGenres() async {
    final endpoint = '/Genres?IncludeItemTypes=Movie,Series,MusicVideo&Recursive=true';
    final url = Uri.parse(ApiConfig.fullUrl(endpoint));

    print('Fetching genres');

    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['Items'] as List<dynamic>?;
      return items?.map((item) => item['Name'] as String).toList() ?? [];
    } else {
      throw Exception('Failed to fetch genres: ${response.body}');
    }
  }
}
