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
    if (_isLoading) return; // prevent concurrent fetches
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.fetchAllContent();
      final musicVideoData = await _apiService.fetchMusicVideos();

      // Build full list — Movie.fromJson now captures the 'Type' field
      final combinedData = [...data, ...musicVideoData];
      _allContent = combinedData.map((json) => Movie.fromJson(json)).toList();

      // Partition using the type stored on each item — no index tricks needed
      _movies     = _allContent.where((item) => item.isMovie).toList();
      _shows      = _allContent.where((item) => item.isSeries).toList();
      _musicVideos = _allContent.where((item) => item.isMusicVideo).toList();

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

  String getImageUrl(String itemId) => _apiService.getImageUrl(itemId);
  String getBackdropUrl(String itemId) => _apiService.getBackdropUrl(itemId);
  String getStreamUrl(String itemId) => _apiService.getStreamUrl(itemId);
}
