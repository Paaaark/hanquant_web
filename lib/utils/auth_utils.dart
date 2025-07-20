import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _loginTimeKey = 'login_time';

  // Save tokens and login time
  static Future<void> saveAuthData(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setInt(_loginTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Retrieve token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Check if login is still valid
  static Future<bool> isLoginValid() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = prefs.getInt(_loginTimeKey);
    if (loginTime == null) return false;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return (currentTime - loginTime) < (10 * 60 * 1000); // 10 minutes
  }

  // Clear stored auth data
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_loginTimeKey);
  }

  // Retrieve username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // Save username
  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }
}
