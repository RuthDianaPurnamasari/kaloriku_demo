import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthManager {
  static const String loginStatusKey = 'loginStatusKey';
  static const String loginTimeKey = 'loginTimeKey';
  static const String usernameKey = 'username';
  static const String tokenKey = 'token';
  static const String demoModeKey = 'kalorikuDemoMode';

  /// Memeriksa apakah pengguna sedang login.
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool(loginStatusKey) ?? false;

    if (!loggedIn) return false;

    // Mode demo tidak memerlukan token backend.
    bool isDemo = prefs.getBool(demoModeKey) ?? false;
    if (isDemo) return true;

    if (!await isTokenValid()) {
      await logout();
      return false;
    }

    return true;
  }

  /// Memeriksa apakah token masih valid.
  static Future<bool> isTokenValid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Token tidak diperlukan dalam mode demo.
    bool isDemo = prefs.getBool(demoModeKey) ?? false;
    if (isDemo) return true;

    String? token = prefs.getString(tokenKey);
    if (token == null || token.isEmpty) return false;

    try {
      return !JwtDecoder.isExpired(token);
    } catch (_) {
      return false;
    }
  }

  /// Login pengguna asli melalui backend.
  static Future<void> login(String username, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginStatusKey, true);
    await prefs.setBool(demoModeKey, false);
    await prefs.setString(loginTimeKey, DateTime.now().toString());
    await prefs.setString(usernameKey, username);
    await prefs.setString(tokenKey, token);
  }

  /// Masuk ke mode demo tanpa backend.
  static Future<void> enableDemoMode(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginStatusKey, true);
    await prefs.setBool(demoModeKey, true);
    await prefs.setString(loginTimeKey, DateTime.now().toString());
    await prefs.setString(usernameKey, username);
    await prefs.remove(tokenKey);
  }

  /// Memeriksa apakah mode demo sedang aktif.
  static Future<bool> isDemoMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(demoModeKey) ?? false;
  }

  /// Mengambil token pengguna.
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  /// Mengambil username pengguna.
  static Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(usernameKey);
  }

  /// Logout dan menghapus data terkait login.
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(loginStatusKey);
    await prefs.remove(loginTimeKey);
    await prefs.remove(usernameKey);
    await prefs.remove(tokenKey);
    await prefs.remove(demoModeKey);
  }

  /// Menghapus semua data tersimpan.
  static Future<void> clearAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
