import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../orders/data/repositories/order_repository.dart';
import '../../../payment/data/repositories/coupon_repository.dart';

/// Badge + tab shell — không dùng [Get.find] cho Cart/Order controller trong bottom bar.
class MainController extends GetxController {
  MainController(this._orderRepository, this._couponRepository);

  final OrderRepository _orderRepository;
  final CouponRepository _couponRepository;

  final selectedIndex = 0.obs;

  /// Tổng số lượng món trong giỏ — đồng bộ từ [CartController] khi giỏ được dùng.
  final cartItemBadgeCount = 0.obs;

  /// Đơn đang xử lý — cập nhật qua repo / đồng bộ từ [OrderController].
  final activeOrderBadgeCount = 0.obs;

  /// Ưu đãi: làm mới từ GET /coupons/public-list; tab Ưu đãi có thể cập nhật lại sau load.
  final availableCouponCount = 0.obs;

  static const int _tabOrders = 2;
  static const _badgeThrottle = Duration(seconds: 30);
  DateTime? _lastBadgeRefresh;

  @override
  void onInit() {
    super.onInit();
    // Sau frame đầu của shell — tránh chen API badge vào cùng lúc layout/tab đầu tiên.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      unawaited(_refreshCouponBadgeFromNetwork());
      unawaited(refreshActiveOrderBadgeFromNetwork());
    });
  }

  Future<void> _refreshCouponBadgeFromNetwork() async {
    try {
      availableCouponCount.value =
          await _couponRepository.fetchPublicCouponBadgeCount();
    } catch (_) {}
  }

  /// Đếm đơn hoạt động — chỉ dùng [OrderRepository], không khởi tạo Order VM.
  Future<void> refreshActiveOrderBadgeFromNetwork() async {
    try {
      final n = await _orderRepository.countActiveOrdersForBadge();
      activeOrderBadgeCount.value = n;
    } catch (_) {}
  }

  void syncActiveOrderBadgeFromOrderTab(int activeCount) {
    activeOrderBadgeCount.value = activeCount;
    _lastBadgeRefresh = DateTime.now();
  }

  void onTabChanged(int index) {
    selectedIndex.value = index;
    if (index == _tabOrders) {
      final now = DateTime.now();
      if (_lastBadgeRefresh == null ||
          now.difference(_lastBadgeRefresh!) > _badgeThrottle) {
        _lastBadgeRefresh = now;
        unawaited(refreshActiveOrderBadgeFromNetwork());
      }
    }
  }
}
