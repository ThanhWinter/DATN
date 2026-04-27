import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxService {
  late final SharedPreferences _prefs;

  final _isAuthenticated = false.obs;
  final _token = RxnString();
  final _refreshToken = RxnString();
  final _avatarUrl = RxnString();

  bool get isAuthenticated => _isAuthenticated.value;
  String? get token => _token.value;
  String? get refreshToken => _refreshToken.value;
  String? get avatarUrl => _avatarUrl.value;

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _savedEmailKey = 'saved_email';
  static const _savedPasswordKey = 'saved_password';
  static const _avatarUrlKey = 'avatar_url';

  Future<AuthService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _token.value = _prefs.getString(_tokenKey);
    _refreshToken.value = _prefs.getString(_refreshTokenKey);
    _avatarUrl.value = _prefs.getString(_avatarUrlKey);
    _isAuthenticated.value = _token.value != null;
    return this;
  }

  String? getUserId() {
    final t = _token.value;
    if (t == null) return null;
    try {
      final parts = t.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      switch (payload.length % 4) {
        case 2:
          payload += '==';
        case 3:
          payload += '=';
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      final claims = jsonDecode(decoded) as Map<String, dynamic>;
      return claims['user-id'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveAvatarUrl(String url) async {
    await _prefs.setString(_avatarUrlKey, url);
    _avatarUrl.value = url;
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
      _prefs.remove(_avatarUrlKey),
    ]);
    _token.value = null;
    _refreshToken.value = null;
    _avatarUrl.value = null;
    _isAuthenticated.value = false;
  }

  String? getToken() => _token.value;
}
