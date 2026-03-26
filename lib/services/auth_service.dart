import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reyrazak/config/app_config.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  String? _errorMessage;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  ApiService get apiService => _apiService;

  // Initialize and check for saved session
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AuthConfig.tokenKey);
      final userId = prefs.getString(AuthConfig.userIdKey);

      if (token != null && token.isNotEmpty && userId != null) {
        _apiService.setAccessToken(token);
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.authenticateByName(username, password);
      _isAuthenticated = true;
      _isLoading = false;

      // Save session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AuthConfig.tokenKey, response['AccessToken'] ?? '');
      await prefs.setString(AuthConfig.userIdKey, response['User']?['Id'] ?? '');
      await prefs.setString(AuthConfig.usernameKey, username);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _apiService.setAccessToken('');

    // Clear saved session
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AuthConfig.tokenKey);
    await prefs.remove(AuthConfig.userIdKey);
    await prefs.remove(AuthConfig.usernameKey);

    notifyListeners();
  }
}
