import 'dart:developer' as dev;

import 'package:get/get.dart';

import '../../../main/presentation/controllers/main_controller.dart';
import '../../../orders/data/models/coupon_model.dart';
import '../../../payment/data/repositories/coupon_repository.dart';

/// Tab Ưu đãi — dữ liệu từ [CouponRepository.fetchAllCoupons] → GET /coupons/public-list.
class CouponListController extends GetxController {
  CouponListController(this._repository);

  final CouponRepository _repository;

  final isLoading = false.obs;
  final error = Rxn<String>();

  /// Cập nhật chỉ khi load / refresh — tránh `.where().toList()` trong Obx.
  final availableCoupons = <CouponModel>[].obs;
  final expiredCoupons = <CouponModel>[].obs;

  bool _isFirstLoad = true;

  void _partitionCoupons(Iterable<CouponModel> source) {
    final now = DateTime.now();
    final av = <CouponModel>[];
    final ex = <CouponModel>[];
    for (final c in source) {
      if (c.isActive && !c.expiresAt.isBefore(now)) {
        av.add(c);
      } else {
        ex.add(c);
      }
    }
    availableCoupons.assignAll(av);
    expiredCoupons.assignAll(ex);
  }

  /// Gọi khi user mở tab Ưu đãi / màn coupon lần đầu (từ view).
  void ensureFirstLoad() {
    if (!_isFirstLoad) return;
    _isFirstLoad = false;
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    try {
      isLoading.value = true;
      error.value = null;
      final list = await _repository.fetchAllCoupons();
      _partitionCoupons(list);
      if (Get.isRegistered<MainController>()) {
        Get.find<MainController>().availableCouponCount.value =
            availableCoupons.length;
      }
      dev.log(
        '[COUPON_LIST] ✅ Loaded ${list.length} coupons '
        '(${availableCoupons.length} available, ${expiredCoupons.length} expired)',
      );
    } catch (e) {
      dev.log('[COUPON_LIST] ❌ loadCoupons error: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
