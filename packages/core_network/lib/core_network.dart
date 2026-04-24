import "dart:convert";
import "dart:isolate";
import "dart:developer" as dev;

import "package:http/http.dart" as http;

abstract class IApiClient {
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? query,
  });

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  });

  void updateToken(String? token);

  void setRefreshToken(String? refreshToken);
}

class AuthHttpClient extends http.BaseClient {
  AuthHttpClient({http.Client? inner, this.token})
      : _inner = inner ?? http.Client();

  final http.Client _inner;
  String? token;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (token != null && token!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    dev.log("🚀 [API REQUEST] ${request.method} ${request.url}");
    if (request is http.Request && request.body.isNotEmpty) {
      dev.log("📦 [BODY] ${request.body}");
    }

    return _inner.send(request);
  }
}

class ApiClient implements IApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    this.defaultHeaders = const {"Content-Type": "application/json"},
    String? token,
    String? refreshToken,
    this.onTokenRefreshed,
    this.onAuthFailed,
  })  : _httpClient = AuthHttpClient(inner: httpClient, token: token),
        _refreshToken = refreshToken;

  final String baseUrl;
  final AuthHttpClient _httpClient;
  final Map<String, String> defaultHeaders;
  String? _refreshToken;
  bool _isRefreshing = false;

  /// Gọi sau khi refresh token thành công để app lưu token mới.
  final Future<void> Function(String accessToken, String? refreshToken)?
      onTokenRefreshed;

  /// Gọi khi refresh thất bại — app nên xóa auth và chuyển về login.
  final Future<void> Function()? onAuthFailed;

  @override
  void updateToken(String? token) {
    _httpClient.token = token;
  }

  @override
  void setRefreshToken(String? refreshToken) {
    _refreshToken = refreshToken;
  }

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    return _withAutoRefresh(() async {
      final response = await _httpClient.get(
        _buildUri(path, query),
        headers: {...defaultHeaders, ...?headers},
      );
      return _handleResponse(response);
    });
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    return _withAutoRefresh(() async {
      final response = await _httpClient.post(
        _buildUri(path),
        headers: {...defaultHeaders, ...?headers},
        body: jsonEncode(body ?? <String, dynamic>{}),
      );
      return _handleResponse(response);
    });
  }

  // =====================================================================
  // AUTO-REFRESH: Khi gặp 401 → tự gọi /auth/refresh-token → retry
  // =====================================================================

  Future<Map<String, dynamic>> _withAutoRefresh(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on ApiException catch (e) {
      if (e.statusCode == 401 && _refreshToken != null && !_isRefreshing) {
        dev.log("🔄 [TOKEN] Access token hết hạn — đang refresh...");
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          return await request();
        }
      }
      rethrow;
    }
  }

  Future<bool> _tryRefreshToken() async {
    _isRefreshing = true;
    try {
      final response = await _httpClient.post(
        _buildUri("/auth/refresh-token"),
        headers: defaultHeaders,
        body: jsonEncode({"refreshToken": _refreshToken}),
      );

      final rawBody = response.body;
      final data = rawBody.isEmpty
          ? <String, dynamic>{}
          : await Isolate.run(
              () => jsonDecode(rawBody) as Map<String, dynamic>);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = data["result"] as Map<String, dynamic>?;
        final newAccessToken = result?["accessToken"] as String?;
        final newRefreshToken = result?["refreshToken"] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          _httpClient.token = newAccessToken;
          if (newRefreshToken != null) {
            _refreshToken = newRefreshToken;
          }
          dev.log("✅ [TOKEN] Refresh thành công");
          await onTokenRefreshed?.call(newAccessToken, newRefreshToken);
          return true;
        }
      }

      dev.log("❌ [TOKEN] Refresh thất bại — status ${response.statusCode}");
      await onAuthFailed?.call();
      return false;
    } catch (e) {
      dev.log("❌ [TOKEN] Refresh exception: $e");
      await onAuthFailed?.call();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Uri _buildUri(String path, [Map<String, String>? query]) {
    return Uri.parse("$baseUrl$path").replace(queryParameters: query);
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final body = response.body;

    dev.log("✅ [API RESPONSE] ${response.statusCode} ${response.request?.url}");
    if (body.isNotEmpty) {
      dev.log("📝 [RESULT] $body");
    }

    final data = body.isEmpty
        ? <String, dynamic>{}
        : await Isolate.run(() => jsonDecode(body) as Map<String, dynamic>);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    dev.log("❌ [API ERROR] ${response.statusCode} - ${data["message"]}");

    throw ApiException(
      statusCode: response.statusCode,
      message: data["message"]?.toString() ?? "Unexpected API error",
      payload: data,
    );
  }
}

class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.message,
    this.payload,
  });

  final int statusCode;
  final String message;
  final Map<String, dynamic>? payload;

  @override
  String toString() {
    return "ApiException($statusCode): $message";
  }
}
