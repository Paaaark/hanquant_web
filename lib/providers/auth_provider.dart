import 'package:flutter/material.dart';
import '../utils/auth_utils.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _token;
  String? _username;
  bool _initialized = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  String? get username => _username;
  bool get initialized => _initialized;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoggedIn = await AuthUtils.isLoginValid();
    _token = await AuthUtils.getToken();
    _username = await AuthUtils.getUsername();
    _initialized = true;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final response = await ApiService.login(username, password);
    await AuthUtils.saveAuthData(response['token'], response['refresh_token']);
    await AuthUtils.saveUsername(username);
    _isLoggedIn = true;
    _token = response['token'];
    _username = username;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthUtils.clearAuthData();
    _isLoggedIn = false;
    _token = null;
    _username = null;
    notifyListeners();
  }

  Future<void> register(String username, String password) async {
    await ApiService.register(username, password);
  }

  Future<void> checkLoginStatus() async {
    _isLoggedIn = await AuthUtils.isLoginValid();
    if (!_isLoggedIn) {
      _token = null;
      _username = null;
    } else {
      _token = await AuthUtils.getToken();
      _username = await AuthUtils.getUsername();
    }
    notifyListeners();
  }
}
