import "dart:convert";
import "dart:isolate";

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
}

class ApiClient implements IApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    this.defaultHeaders = const {"Content-Type": "application/json"},
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;
  final Map<String, String> defaultHeaders;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    final response = await _httpClient.get(
      _buildUri(path, query),
      headers: {...defaultHeaders, ...?headers},
    );
    return _handleResponse(response);
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final response = await _httpClient.post(
      _buildUri(path),
      headers: {...defaultHeaders, ...?headers},
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _handleResponse(response);
  }

  Uri _buildUri(String path, [Map<String, String>? query]) {
    return Uri.parse("$baseUrl$path").replace(queryParameters: query);
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final body = response.body;
    final data = body.isEmpty
        ? <String, dynamic>{}
        : await Isolate.run(() => jsonDecode(body) as Map<String, dynamic>);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

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
