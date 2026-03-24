import 'package:flutter/foundation.dart';
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

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.authenticateByName(username, password);
      _isAuthenticated = true;
      _isLoading = false;
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

  void logout() {
    _isAuthenticated = false;
    _apiService.setAccessToken('');
    notifyListeners();
  }
}
