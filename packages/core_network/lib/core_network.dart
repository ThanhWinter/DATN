import "dart:async";
import "dart:convert";
import "dart:developer" as dev;
import "dart:isolate";
import "dart:typed_data";

import "package:http/http.dart" as http;
import "package:http_parser/http_parser.dart";

/// Tránh log response JSON khổng lồ trong bản release (RAM / chồng log DevTools).
const bool _isReleaseMode = bool.fromEnvironment("dart.vm.product");
const int _maxLoggedBodyChars = 2500;

// Threshold 10 KB: nhỏ hơn thì parse trực tiếp, lớn hơn thì ném sang isolate.
const int _isolateThreshold = 10 * 1024;

// Đọc StreamedResponse theo từng chunk với giới hạn kích thước.
// Thay thế http.Response.fromStream để tránh RAM spike khi server trả về dữ liệu lớn.
const int _maxResponseBytes = 8 * 1024 * 1024; // 8 MB

Future<http.Response> _readStreamedResponse(http.StreamedResponse streamed) async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in streamed.stream) {
    builder.add(chunk);
    if (builder.length > _maxResponseBytes) {
      throw ApiException(
        statusCode: streamed.statusCode,
        message: 'Response vượt giới hạn ${_maxResponseBytes ~/ (1024 * 1024)} MB',
      );
    }
  }
  return http.Response.bytes(
    builder.takeBytes(),
    streamed.statusCode,
    headers: streamed.headers,
    request: streamed.request,
    isRedirect: streamed.isRedirect,
    persistentConnection: streamed.persistentConnection,
    reasonPhrase: streamed.reasonPhrase,
  );
}

Future<Map<String, dynamic>> _parseResponseBodyToMap(String body) async {
  if (body.isEmpty) return <String, dynamic>{};
  if (body.length > _isolateThreshold) {
    return await Isolate.run(() => jsonDecode(body) as Map<String, dynamic>);
  }
  return jsonDecode(body) as Map<String, dynamic>;
}

/// Record dùng cho multipart file upload.
typedef MultipartFileData = ({
  String field,
  List<int> bytes,
  String filename,
  String contentType,
});

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

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  });

  /// [query] merge vào query params của URL (giữ nguyên params có sẵn trong path).
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, String>? query,
  });

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? headers,
  });

  /// Upload multipart/form-data. Bytes đã có trong RAM nên retry an toàn khi token hết hạn.
  Future<Map<String, dynamic>> multipartPost(
    String path, {
    Map<String, String>? fields,
    List<MultipartFileData>? files,
  });

  /// Tương tự multipartPost nhưng dùng HTTP PUT (dùng để cập nhật resource có file).
  Future<Map<String, dynamic>> multipartPut(
    String path, {
    Map<String, String>? fields,
    List<MultipartFileData>? files,
  });

  /// Upload file và trả về raw string body (dùng cho endpoint trả về plain URL, không wrap ApiResponse).
  Future<String> uploadRaw(String path, MultipartFileData file);

  void updateToken(String? token);
  void setRefreshToken(String? refreshToken);
}

// =========================================================================
// AuthHttpClient — tự động đính Bearer token vào mọi request (kể cả multipart).
// =========================================================================

class AuthHttpClient extends http.BaseClient {
  AuthHttpClient({http.Client? inner, this.token})
      : _inner = inner ?? http.Client();

  final http.Client _inner;
  String? token;

  static const Duration _timeout = Duration(seconds: 20);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (token != null && token!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    dev.log('🚀 [API] ${request.method} ${request.url}');
    try {
      return await _inner.send(request).timeout(_timeout);
    } on TimeoutException {
      throw ApiException(
        statusCode: 408,
        message: 'Kết nối quá lâu. Vui lòng kiểm tra mạng và thử lại.',
      );
    }
  }
}

// =========================================================================
// ApiClient — triển khai đầy đủ IApiClient.
// =========================================================================

class ApiClient implements IApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    this.defaultHeaders = const {'Content-Type': 'application/json'},
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

  final Future<void> Function(String accessToken, String? refreshToken)?
      onTokenRefreshed;
  final Future<void> Function()? onAuthFailed;

  @override
  void updateToken(String? token) => _httpClient.token = token;

  @override
  void setRefreshToken(String? refreshToken) => _refreshToken = refreshToken;

  // -----------------------------------------------------------------------
  // GET
  // -----------------------------------------------------------------------

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? query,
  }) =>
      _withAutoRefresh(() async {
        final res = await _httpClient.get(
          _buildUri(path, query),
          headers: {
            'Accept': 'application/json',
            ...?headers,
          },
        );
        return _handleResponse(res);
      });

  // -----------------------------------------------------------------------
  // POST
  // -----------------------------------------------------------------------

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) =>
      _withAutoRefresh(() async {
        if (body != null && body.isNotEmpty && !_isReleaseMode) {
          final raw = jsonEncode(body);
          dev.log(
            '📤 [BODY] ${raw.length > _maxLoggedBodyChars ? '${raw.substring(0, _maxLoggedBodyChars)}…' : raw}',
          );
        }
        final res = await _httpClient.post(
          _buildUri(path),
          headers: {
            'Accept': 'application/json',
            ...defaultHeaders,
            ...?headers,
          },
          body: jsonEncode(body ?? <String, dynamic>{}),
        );
        return await _handleResponse(res);
      });

  // -----------------------------------------------------------------------
  // PUT
  // -----------------------------------------------------------------------

  @override
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) =>
      _withAutoRefresh(() async {
        if (body != null && body.isNotEmpty && !_isReleaseMode) {
          final raw = jsonEncode(body);
          dev.log(
            '📤 [BODY] ${raw.length > _maxLoggedBodyChars ? '${raw.substring(0, _maxLoggedBodyChars)}…' : raw}',
          );
        }
        final res = await _httpClient.put(
          _buildUri(path),
          headers: {...defaultHeaders, ...?headers},
          body: jsonEncode(body ?? <String, dynamic>{}),
        );
        return await _handleResponse(res);
      });

  // -----------------------------------------------------------------------
  // PATCH  — hỗ trợ query params (dùng cho /orders/{id}/status?status=X)
  // -----------------------------------------------------------------------

  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) =>
      _withAutoRefresh(() async {
        if (body != null && body.isNotEmpty && !_isReleaseMode) {
          final raw = jsonEncode(body);
          dev.log(
            '📤 [BODY] ${raw.length > _maxLoggedBodyChars ? '${raw.substring(0, _maxLoggedBodyChars)}…' : raw}',
          );
        }
        final res = await _httpClient.patch(
          _buildUri(path, query),
          headers: {...defaultHeaders, ...?headers},
          body: body != null ? jsonEncode(body) : null,
        );
        return _handleResponse(res);
      });

  // -----------------------------------------------------------------------
  // DELETE
  // -----------------------------------------------------------------------

  @override
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? headers,
  }) =>
      _withAutoRefresh(() async {
        final res = await _httpClient.delete(
          _buildUri(path),
          headers: {
            'Accept': 'application/json',
            ...?headers,
          },
        );
        return await _handleResponse(res);
      });

  // -----------------------------------------------------------------------
  // MULTIPART POST
  // -----------------------------------------------------------------------

  @override
  Future<Map<String, dynamic>> multipartPost(
    String path, {
    Map<String, String>? fields,
    List<MultipartFileData>? files,
  }) =>
      _withAutoRefresh(() async {
        final request = http.MultipartRequest('POST', _buildUri(path));
        if (fields != null) request.fields.addAll(fields);
        if (files != null) {
          for (final f in files) {
            request.files.add(http.MultipartFile.fromBytes(
              f.field,
              f.bytes,
              filename: f.filename,
              contentType: MediaType.parse(f.contentType),
            ));
          }
        }
        dev.log('🚀 [API MULTIPART] POST ${request.url} | fields: ${request.fields.keys.toList()}');
        final streamed = await _httpClient.send(request);
        final res = await _readStreamedResponse(streamed);
        return await _handleResponse(res);
      });

  // -----------------------------------------------------------------------
  // MULTIPART PUT
  // -----------------------------------------------------------------------

  @override
  Future<Map<String, dynamic>> multipartPut(
    String path, {
    Map<String, String>? fields,
    List<MultipartFileData>? files,
  }) =>
      _withAutoRefresh(() async {
        final request = http.MultipartRequest('PUT', _buildUri(path));
        if (fields != null) request.fields.addAll(fields);
        if (files != null) {
          for (final f in files) {
            request.files.add(http.MultipartFile.fromBytes(
              f.field,
              f.bytes,
              filename: f.filename,
              contentType: MediaType.parse(f.contentType),
            ));
          }
        }
        dev.log('🚀 [API MULTIPART] PUT ${request.url} | fields: ${request.fields.keys.toList()}');
        final streamed = await _httpClient.send(request);
        final res = await _readStreamedResponse(streamed);
        return await _handleResponse(res);
      });

  // -----------------------------------------------------------------------
  // UPLOAD RAW — trả về plain string body (không wrap ApiResponse)
  // -----------------------------------------------------------------------

  @override
  Future<String> uploadRaw(String path, MultipartFileData file) async {
    final request = http.MultipartRequest('POST', _buildUri(path));
    request.files.add(http.MultipartFile.fromBytes(
      file.field,
      file.bytes,
      filename: file.filename,
    ));
    dev.log('🚀 [API UPLOAD] POST ${request.url}');
    final streamed = await _httpClient.send(request);
    final res = await _readStreamedResponse(streamed);
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    dev.log('${ok ? '✅' : '❌'} [API UPLOAD] ${res.statusCode} → ${res.body}');
    if (ok) return res.body.trim();
    throw ApiException(
      statusCode: res.statusCode,
      message: res.body.trim().isNotEmpty ? res.body.trim() : 'Upload failed',
    );
  }

  // =========================================================================
  // AUTO-REFRESH: 401 → refresh token → retry một lần
  // =========================================================================

  Future<Map<String, dynamic>> _withAutoRefresh(
    Future<Map<String, dynamic>> Function() call,
  ) async {
    try {
      return await call();
    } on ApiException catch (e) {
      if (e.statusCode == 401 && _refreshToken != null && !_isRefreshing) {
        dev.log('🔄 [TOKEN] Access token hết hạn — đang refresh...');
        if (await _tryRefreshToken()) return await call();
      }
      rethrow;
    }
  }

  Future<bool> _tryRefreshToken() async {
    _isRefreshing = true;
    try {
      final cleanClient = http.Client();
      final res = await cleanClient.post(
        _buildUri('/auth/refresh-token'),
        headers: defaultHeaders,
        body: jsonEncode({'refreshToken': _refreshToken}),
      );
      cleanClient.close();
      final body = res.body;
      final data = await _parseResponseBodyToMap(body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final result = data['result'] as Map<String, dynamic>?;
        final newAccess = result?['accessToken'] as String?;
        final newRefresh = result?['refreshToken'] as String?;
        if (newAccess != null && newAccess.isNotEmpty) {
          updateToken(newAccess);
          setRefreshToken(newRefresh);
          dev.log('✅ [TOKEN] Refresh thành công');
          await onTokenRefreshed?.call(newAccess, newRefresh);
          return true;
        }
      }
      dev.log('❌ [TOKEN] Refresh thất bại — status ${res.statusCode}');
      await onAuthFailed?.call();
      return false;
    } catch (e) {
      dev.log('❌ [TOKEN] Refresh exception: $e');
      await onAuthFailed?.call();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // =========================================================================
  // HELPERS
  // =========================================================================

  /// Merge query params trong [path] với [extra], không xoá params có sẵn.
  Uri _buildUri(String path, [Map<String, String>? extra]) {
    final uri = Uri.parse('$baseUrl$path');
    if (extra == null || extra.isEmpty) return uri;
    return uri.replace(
      queryParameters: {...uri.queryParameters, ...extra},
    );
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response res) async {
    final body = res.body;
    final ok = res.statusCode >= 200 && res.statusCode < 300;

    dev.log('${ok ? '✅' : '❌'} [API] ${res.statusCode} ${res.request?.url}');
    if (body.isNotEmpty && !_isReleaseMode) {
      final preview = body.length > _maxLoggedBodyChars
          ? '${body.substring(0, _maxLoggedBodyChars)}… (${body.length} chars)'
          : body;
      dev.log('📝 [RESULT] $preview');
    }

    if (res.statusCode == 204) return <String, dynamic>{};

    final data = await _parseResponseBodyToMap(body);

    if (ok) return data;

    final message = data['message']?.toString() ?? 'Unexpected API error';
    dev.log(
      '🔴 [ERROR] ${res.statusCode} — $message',
      error: data,
      level: 1000, // ERROR level — nổi bật hơn trong DevTools Logging tab
    );
    throw ApiException(
      statusCode: res.statusCode,
      message: message,
      payload: data,
    );
  }
}

// =========================================================================
// ApiException
// =========================================================================

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.payload,
  });

  final int statusCode;
  final String message;
  final Map<String, dynamic>? payload;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
