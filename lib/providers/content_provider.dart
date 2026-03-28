import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class ContentProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Movie> _movies = [];
  List<Movie> _shows = [];
  List<Movie> _musicVideos = [];
  List<Movie> _allContent = [];
  bool _isLoading = false;
  String? _errorMessage;

  ContentProvider(this._apiService);

  List<Movie> get movies => _movies;
  List<Movie> get shows => _shows;
  List<Movie> get musicVideos => _musicVideos;
  List<Movie> get allContent => _allContent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiService get apiService => _apiService;

  Future<void> fetchAllContent() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.fetchAllContent();

      // Also fetch music videos
      final musicVideoData = await _apiService.fetchMusicVideos();

      // Combine all content
      final combinedData = [...data, ...musicVideoData];
      _allContent = combinedData.map((json) => Movie.fromJson(json)).toList();

      _movies = _allContent.where((item) =>
        combinedData[_allContent.indexOf(item)]['Type'] == 'Movie'
      ).toList();

      _shows = _allContent.where((item) =>
        combinedData[_allContent.indexOf(item)]['Type'] == 'Series'
      ).toList();

      _musicVideos = _allContent.where((item) =>
        combinedData[_allContent.indexOf(item)]['Type'] == 'MusicVideo'
      ).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMovies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.fetchMovies();
      _movies = data.map((json) => Movie.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchShows() async {
    try {
      final data = await _apiService.fetchShows();
      _shows = data.map((json) => Movie.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  String getImageUrl(String itemId) {
    return _apiService.getImageUrl(itemId);
  }

  String getBackdropUrl(String itemId) {
    return _apiService.getBackdropUrl(itemId);
  }

  String getStreamUrl(String itemId) {
    return _apiService.getStreamUrl(itemId);
  }
}
