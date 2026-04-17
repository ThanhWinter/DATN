import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Tiện ích log tập trung — chỉ hoạt động ở debug mode, tắt hoàn toàn ở release.
///
/// Cách dùng:
///   AppLogger.d('CartController', 'Item added: $id');
///   AppLogger.e('ApiClient', 'Request failed', error, stackTrace);
class AppLogger {
  AppLogger._();

  /// Debug — thông tin chi tiết khi phát triển.
  static void d(String tag, String message) {
    if (kDebugMode) {
      developer.log(message, name: tag, level: 500);
    }
  }

  /// Info — sự kiện quan trọng trong luồng chạy.
  static void i(String tag, String message) {
    if (kDebugMode) {
      developer.log(message, name: tag, level: 800);
    }
  }

  /// Warning — tình huống không mong muốn nhưng app vẫn tiếp tục.
  static void w(String tag, String message) {
    if (kDebugMode) {
      developer.log('[WARN] $message', name: tag, level: 900);
    }
  }

  /// Error — lỗi cần xử lý, in kèm error object và stack trace.
  static void e(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      developer.log(
        '[ERROR] $message',
        name: tag,
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
