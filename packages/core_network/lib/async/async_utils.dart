import 'dart:async';
import 'dart:developer' as dev;

typedef VoidCallback = void Function();

/// Utility class for async operations and performance optimization
class AsyncUtils {
  /// Execute multiple futures concurrently with timeout and error handling
  static Future<List<T>> parallel<T>(
    Iterable<Future<T> Function()> futures, {
    Duration timeout = const Duration(seconds: 30),
    bool failFast = false,
  }) async {
    if (failFast) {
      return await Future.wait(
        futures.map((f) => f().timeout(timeout)),
        eagerError: true,
      );
    }

    final results = <T?>[]..length = futures.length;
    final errors = <int, dynamic>{};
    final completer = Completer<List<T>>();

    int completed = 0;
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < futures.length; i++) {
      futures.elementAt(i)().timeout(timeout).then((result) {
        results[i] = result;
        completed++;
        if (completed == futures.length) {
          stopwatch.stop();
          dev.log(
              '[ASYNC] Parallel completed in ${stopwatch.elapsedMilliseconds}ms');
          completer.complete(results.cast<T>());
        }
      }).catchError((error) {
        errors[i] = error;
        completed++;
        if (completed == futures.length) {
          stopwatch.stop();
          dev.log(
              '[ASYNC] Parallel completed with ${errors.length} errors in ${stopwatch.elapsedMilliseconds}ms');
          if (errors.isNotEmpty) {
            completer.completeError(errors);
          } else {
            completer.complete(results.cast<T>());
          }
        }
      });
    }

    return completer.future;
  }

  /// Debounce function calls
  static Timer? _debounceTimer;
  static void debounce(
    VoidCallback callback,
    Duration delay, {
    String? key,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle function calls
  static DateTime _lastThrottleTime = DateTime.now();
  static bool throttle(
    VoidCallback callback,
    Duration interval, {
    String? key,
  }) {
    final now = DateTime.now();
    if (now.difference(_lastThrottleTime) >= interval) {
      _lastThrottleTime = now;
      callback();
      return true;
    }
    return false;
  }

  /// Retry mechanism with exponential backoff
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
  }) async {
    dynamic lastError;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;
        if (attempt == maxAttempts) rethrow;

        final delay = Duration(
          milliseconds: (initialDelay.inMilliseconds *
                  (backoffMultiplier * (attempt - 1)))
              .round(),
        );

        dev.log(
            '[ASYNC] Retry $attempt/$maxAttempts failed, retrying in ${delay.inMilliseconds}ms: $error');
        await Future.delayed(delay);
      }
    }

    throw lastError;
  }

  /// Memoize expensive async operations
  static final Map<String, Future<dynamic>> _memoCache = {};

  static Future<T> memoize<T>(
    String key,
    Future<T> Function() operation, {
    Duration? ttl,
  }) {
    final existing = _memoCache[key] as Future<T>?;
    if (existing != null) {
      dev.log('[ASYNC] Memo cache hit: $key');
      return existing;
    }

    final future = operation();
    _memoCache[key] = future;

    if (ttl != null) {
      Future.delayed(ttl).then((_) {
        _memoCache.remove(key);
        dev.log('[ASYNC] Memo cache expired: $key');
      });
    }

    return future;
  }

  /// Batch operations for better performance
  static Future<List<T>> batch<T>(
    List<T> items,
    Future<void> Function(List<T>) batchOperation, {
    int batchSize = 10,
    Duration delayBetweenBatches = const Duration(milliseconds: 50),
  }) async {
    final results = <T>[];

    for (int i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize).toList();
      await batchOperation(batch);
      results.addAll(batch);

      if (i + batchSize < items.length) {
        await Future.delayed(delayBetweenBatches);
      }
    }

    return results;
  }
}
