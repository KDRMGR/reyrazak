import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class MovieProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _errorMessage;

  MovieProvider(this._apiService);

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  String getImageUrl(String movieId) {
    return _apiService.getImageUrl(movieId);
  }

  String getBackdropUrl(String movieId) {
    return _apiService.getBackdropUrl(movieId);
  }

  String getStreamUrl(String movieId) {
    return _apiService.getStreamUrl(movieId);
  }
}
