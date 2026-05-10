import 'dart:async';
import 'dart:developer' as dev;


import 'core_network.dart';

/// Optimized API client with caching and performance improvements
class OptimizedApiClient implements IApiClient {
  OptimizedApiClient({
    required this.baseUrl,
    required this.innerClient,
    this.defaultHeaders = const {'Content-Type': 'application/json'},
    this.enableCache = true,
    this.cacheTtl = const Duration(minutes: 5),
  });

  final String baseUrl;
  final IApiClient innerClient;
  final Map<String, String> defaultHeaders;
  final bool enableCache;
  final Duration cacheTtl;

  final Map<String, Future<Map<String, dynamic>>> _pendingRequests = {};

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    final cacheKey = _buildCacheKey('GET', path, query);

    if (enableCache) {
      final cached = apiCache.get(cacheKey);
      if (cached != null) {
        dev.log('[OPTIMIZED_API] Cache hit: $path');
        return cached;
      }
    }

    // Prevent duplicate requests
    if (_pendingRequests.containsKey(cacheKey)) {
      dev.log('[OPTIMIZED_API] Request deduplication: $path');
      return await _pendingRequests[cacheKey]!;
    }

    final future = innerClient.get(path, headers: headers, query: query);
    _pendingRequests[cacheKey] = future;

    try {
      final result = await future;

      if (enableCache) {
        apiCache.set(cacheKey, result, ttl: cacheTtl);
      }

      return result;
    } finally {
      _pendingRequests.remove(cacheKey);
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final result = await innerClient.post(path, headers: headers, body: body);
    _invalidateRelevantCache(path);
    return result;
  }

  @override
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final result = await innerClient.put(path, headers: headers, body: body);
    _invalidateRelevantCache(path);
    return result;
  }

  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final result = await innerClient.patch(
      path,
      headers: headers,
      body: body,
      query: query,
    );
    _invalidateRelevantCache(path);
    return result;
  }

  @override
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    final result = await innerClient.delete(path, headers: headers);
    _invalidateRelevantCache(path);
    return result;
  }

  @override
  Future<Map<String, dynamic>> multipartPost(
    String path, {
    Map<String, String>? fields,
    List<MultipartFileData>? files,
  }) async {
    final result = await innerClient.multipartPost(
      path,
      fields: fields,
      files: files,
    );
    _invalidateRelevantCache(path);
    return result;
  }

  @override
  Future<Map<String, dynamic>> multipartPut(
    String path, {
    Map<String, String>? fields,
    List<MultipartFileData>? files,
  }) async {
    final result = await innerClient.multipartPut(
      path,
      fields: fields,
      files: files,
    );
    _invalidateRelevantCache(path);
    return result;
  }

  @override
  Future<String> uploadRaw(String path, MultipartFileData file) async {
    final result = await innerClient.uploadRaw(path, file);
    _invalidateRelevantCache(path);
    return result;
  }

  @override
  void updateToken(String? token) => innerClient.updateToken(token);

  @override
  void setRefreshToken(String? refreshToken) =>
      innerClient.setRefreshToken(refreshToken);

  String _buildCacheKey(
      String method, String path, Map<String, String>? query) {
    final queryString =
        query?.entries.map((e) => '${e.key}=${e.value}').join('&') ?? '';
    return '${method}_${path}_$queryString';
  }

  void _invalidateRelevantCache(String path) {
    if (!enableCache) return;

    // Simple cache invalidation - in production, you might want more sophisticated logic
    final keysToInvalidate = apiCache.keys.where((key) => key.contains(
            path.split('/').where((segment) => segment.isNotEmpty).first))
        .toList();

    for (final key in keysToInvalidate) {
      apiCache.invalidate(key);
    }

    dev.log(
        '[OPTIMIZED_API] Invalidated ${keysToInvalidate.length} cache entries for $path');
  }

  /// Clear all cache
  void clearCache() {
    if (enableCache) {
      apiCache.clear();
    }
  }

  /// Preload common data
  Future<void> preloadData(List<String> paths) async {
    if (!enableCache) return;

    dev.log('[OPTIMIZED_API] Preloading ${paths.length} endpoints');

    await Future.wait(
      paths.map((path) => get(path)),
      eagerError: false,
    );

    dev.log('[OPTIMIZED_API] Preloading completed');
  }
}
