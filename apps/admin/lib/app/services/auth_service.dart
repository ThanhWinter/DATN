import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxService {
  late final SharedPreferences _prefs;

  final _isAuthenticated = false.obs;
  final _token = RxnString();
  final _refreshToken = RxnString();

  bool get isAuthenticated => _isAuthenticated.value;
  String? get token => _token.value;
  String? get refreshToken => _refreshToken.value;

  static const _tokenKey = 'admin_auth_token';
  static const _refreshTokenKey = 'admin_refresh_token';
  static const _savedEmailKey = 'admin_saved_email';
  static const _savedPasswordKey = 'admin_saved_password';

  Future<AuthService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _token.value = _prefs.getString(_tokenKey);
    _refreshToken.value = _prefs.getString(_refreshTokenKey);
    _isAuthenticated.value = _token.value != null;
    return this;
  }

  Future<void> saveToken(String token, {String? refreshToken}) async {
    await Future.wait([
      _prefs.setString(_tokenKey, token),
      if (refreshToken != null)
        _prefs.setString(_refreshTokenKey, refreshToken),
    ]);
    _token.value = token;
    if (refreshToken != null) _refreshToken.value = refreshToken;
    _isAuthenticated.value = true;
  }

  Future<void> saveCredentials(String email, String password) async {
    await Future.wait([
      _prefs.setString(_savedEmailKey, email),
      _prefs.setString(_savedPasswordKey, password),
    ]);
  }

  Future<Map<String, String?>> getSavedCredentials() async {
    return {
      'email': _prefs.getString(_savedEmailKey),
      'password': _prefs.getString(_savedPasswordKey),
    };
  }

  Future<void> clearSavedCredentials() async {
    await Future.wait([
      _prefs.remove(_savedEmailKey),
      _prefs.remove(_savedPasswordKey),
    ]);
  }

  Future<void> clearAuth() async {
    await Future.wait([
      _prefs.remove(_tokenKey),
      _prefs.remove(_refreshTokenKey),
    ]);
    _token.value = null;
    _refreshToken.value = null;
    _isAuthenticated.value = false;
  }

  String? getToken() => _token.value;
}
