import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../orders/data/repositories/order_repository.dart';

/// Shell bottom bar — badge không gọi [Get.find] cho Order VM.
class MainController extends GetxController {
  MainController(this._orderRepository);

  final OrderRepository _orderRepository;

  final currentIndex = 0.obs;

  /// PENDING + PAID + PREPARING + DELIVERING (chờ xác nhận + đang xử lý).
  final pendingOrderBadgeCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      unawaited(refreshPendingBadgeFromNetwork());
    });
  }

  Future<void> refreshPendingBadgeFromNetwork() async {
    try {
      final n = await _orderRepository.fetchPendingBucketBadgeCount();
      pendingOrderBadgeCount.value = n;
    } catch (_) {}
  }

  void syncPendingBadgeFromOrderTab(int count) {
    pendingOrderBadgeCount.value = count;
  }

  void changePage(int index) {
    currentIndex.value = index;
    if (index == 1) {
      refreshPendingBadgeFromNetwork();
    }
  }
}
