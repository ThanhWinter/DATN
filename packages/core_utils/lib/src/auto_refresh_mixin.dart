import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Mixin cho GetxController để tự động polling data theo chu kỳ.
///
/// - Tự dừng khi app vào background, tự tiếp tục khi app trở về foreground.
/// - Gọi [startPolling] trong [onInit]. Không cần gọi [stopPolling] thủ công —
///   mixin tự dọn dẹp trong [onClose].
///
/// Ví dụ:
/// ```dart
/// class MyController extends GetxController with AutoRefreshMixin {
///   @override
///   void onInit() {
///     super.onInit();
///     loadData();
///     startPolling(const Duration(seconds: 60), _silentRefresh);
///   }
/// }
/// ```
mixin AutoRefreshMixin on GetxController {
  Timer? _pollTimer;
  _LifecycleObserver? _lifecycleObserver;

  /// Bắt đầu polling [onTick] mỗi [interval].
  /// Tự pause khi app vào background, resume + gọi [onTick] ngay khi trở về.
  void startPolling(Duration interval, Future<void> Function() onTick) {
    _pollTimer?.cancel();
    _lifecycleObserver?.remove();

    void startTimer() {
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(interval, (_) {
        if (!isClosed) onTick();
      });
    }

    _lifecycleObserver = _LifecycleObserver(
      onPause: () => _pollTimer?.cancel(),
      onResume: () {
        onTick();
        startTimer();
      },
    );

    startTimer();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _lifecycleObserver?.remove();
    super.onClose();
  }
}

class _LifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onPause;
  final VoidCallback onResume;

  _LifecycleObserver({required this.onPause, required this.onResume}) {
    WidgetsBinding.instance.addObserver(this);
  }

  void remove() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      onPause();
    } else if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}
