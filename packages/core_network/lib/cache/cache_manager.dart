import 'dart:developer' as dev;

/// Simple in-memory cache with TTL support
class CacheManager<T> {
  CacheManager({Duration? defaultTtl})
      : _defaultTtl = defaultTtl ?? const Duration(minutes: 5);

  final Duration _defaultTtl;
  final Map<String, _CacheEntry<T>> _cache = {};

  Iterable<String> get keys => _cache.keys;

  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.expiresAt.isBefore(DateTime.now())) {
      _cache.remove(key);
      assert(() { dev.log('[CACHE] Expired: $key'); return true; }());
      return null;
    }

    assert(() { dev.log('[CACHE] Hit: $key'); return true; }());
    return entry.value;
  }

  void set(String key, T value, {Duration? ttl}) {
    final expiresAt = DateTime.now().add(ttl ?? _defaultTtl);
    _cache[key] = _CacheEntry(value, expiresAt);
    assert(() {
      dev.log('[CACHE] Set: $key (expires in ${(ttl ?? _defaultTtl).inMinutes}min)');
      return true;
    }());
  }

  void invalidate(String key) {
    _cache.remove(key);
    assert(() { dev.log('[CACHE] Invalidated: $key'); return true; }());
  }

  void clear() {
    _cache.clear();
    assert(() { dev.log('[CACHE] Cleared all entries'); return true; }());
  }

  /// Xóa tất cả entries đã hết hạn khỏi bộ nhớ.
  void cleanExpired() {
    final now = DateTime.now();
    _cache.removeWhere((_, entry) => entry.expiresAt.isBefore(now));
  }

  int get size => _cache.length;
}

class _CacheEntry<T> {
  _CacheEntry(this.value, this.expiresAt);

  final T value;
  final DateTime expiresAt;
}

/// Global cache instances
final apiCache =
    CacheManager<Map<String, dynamic>>(defaultTtl: const Duration(minutes: 5));
final imageCache = CacheManager<String>(defaultTtl: const Duration(hours: 1));
