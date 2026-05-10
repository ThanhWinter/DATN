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
      dev.log('[CACHE] Expired: $key');
      return null;
    }

    dev.log('[CACHE] Hit: $key');
    return entry.value;
  }

  void set(String key, T value, {Duration? ttl}) {
    final expiresAt = DateTime.now().add(ttl ?? _defaultTtl);
    _cache[key] = _CacheEntry(value, expiresAt);
    dev.log(
        '[CACHE] Set: $key (expires in ${(ttl ?? _defaultTtl).inMinutes}min)');
  }

  void invalidate(String key) {
    _cache.remove(key);
    dev.log('[CACHE] Invalidated: $key');
  }

  void clear() {
    _cache.clear();
    dev.log('[CACHE] Cleared all entries');
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
