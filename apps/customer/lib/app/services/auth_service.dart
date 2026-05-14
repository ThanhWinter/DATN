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
  static const _userProfileKey = 'user_profile';
  static const _avatarPromptSeenKey = 'avatar_prompt_seen';

  /// Cache the parsed `user-id` for the current access token (no repeated decode).
  String? _cachedUserId;
  String? _userIdCacheToken;

  void _invalidateUserIdCache() {
    _cachedUserId = null;
    _userIdCacheToken = null;
  }

  Future<AuthService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _token.value = _prefs.getString(_tokenKey);
    _refreshToken.value = _prefs.getString(_refreshTokenKey);
    _avatarUrl.value = _prefs.getString(_avatarUrlKey);
    _isAuthenticated.value = _token.value != null;
    _invalidateUserIdCache();
    return this;
  }

  /// JWT payload `user-id` — lightweight string parse (no `jsonDecode` on UI isolate).
  static String? _parseUserIdFromJwtPayload(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1];
      switch (payload.length % 4) {
        case 2:
          payload += '==';
        case 3:
          payload += '=';
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      final m = RegExp(
        r'''["']user-id["']\s*:\s*["']([^"']+)["']''',
      ).firstMatch(decoded);
      return m?.group(1);
    } catch (_) {
      return null;
    }
  }

  String? getUserId() {
    final t = _token.value;
    if (t == null) {
      _invalidateUserIdCache();
      return null;
    }
    if (_userIdCacheToken == t) return _cachedUserId;
    _userIdCacheToken = t;
    _cachedUserId = _parseUserIdFromJwtPayload(t);
    return _cachedUserId;
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
    _invalidateUserIdCache();
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
      _prefs.remove(_avatarPromptSeenKey),
    ]);
    _token.value = null;
    _refreshToken.value = null;
    _avatarUrl.value = null;
    _isAuthenticated.value = false;
    _invalidateUserIdCache();
  }

  bool hasSeenAvatarPrompt() =>
      _prefs.getBool(_avatarPromptSeenKey) ?? false;

  Future<void> markAvatarPromptSeen() =>
      _prefs.setBool(_avatarPromptSeenKey, true);

  Future<void> saveUserProfile(Map<String, dynamic> userJson) async {
    await _prefs.setString(_userProfileKey, jsonEncode(userJson));
  }

  Map<String, dynamic>? getUserProfile() {
    final raw = _prefs.getString(_userProfileKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String? getToken() => _token.value;
}
