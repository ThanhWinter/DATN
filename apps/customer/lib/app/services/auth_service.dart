import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final _storage = const FlutterSecureStorage();
  final _isAuthenticated = false.obs;
  final _token = RxnString();
  final _refreshToken = RxnString();

  bool get isAuthenticated => _isAuthenticated.value;
  String? get token => _token.value;
  String? get refreshToken => _refreshToken.value;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';

  Future<AuthService> init() async {
    _token.value = await _storage.read(key: _tokenKey);
    _refreshToken.value = await _storage.read(key: _refreshTokenKey);
    _isAuthenticated.value = _token.value != null;
    return this;
  }

  Future<void> saveToken(String token, {String? refreshToken}) async {
    await _storage.write(key: _tokenKey, value: token);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      _refreshToken.value = refreshToken;
    }
    _token.value = token;
    _isAuthenticated.value = true;
  }

  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _savedEmailKey, value: email);
    await _storage.write(key: _savedPasswordKey, value: password);
  }

  Future<Map<String, String?>> getSavedCredentials() async {
    final email = await _storage.read(key: _savedEmailKey);
    final password = await _storage.read(key: _savedPasswordKey);
    return {'email': email, 'password': password};
  }

  Future<void> clearSavedCredentials() async {
    await _storage.delete(key: _savedEmailKey);
    await _storage.delete(key: _savedPasswordKey);
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    _token.value = null;
    _refreshToken.value = null;
    _isAuthenticated.value = false;
  }

  String? getToken() => _token.value;
}
