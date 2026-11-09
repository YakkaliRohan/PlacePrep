import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  bool get isGuest => _user?.isGuest ?? true;
  bool get isAdmin => _user?.role == 'admin';

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _api.init();
      _user = await _api.getMe();
    } catch (_) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _api.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _api.signup(name, email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> guestLogin([String name = "Guest Explorer"]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _api.guestLogin(name);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Offline / GitHub Pages fallback
      _user = UserModel(
        id: 1,
        email: 'guest@placeprep.in',
        name: name,
        role: 'user',
        isGuest: true,
        testsTaken: 24,
        totalAccuracy: 78.0,
        questionsSolved: 412,
        streak: 7,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    notifyListeners();
  }
}
