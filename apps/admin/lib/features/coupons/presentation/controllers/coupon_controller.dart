import 'dart:developer' as dev;

import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../data/models/coupon_model.dart';
import '../../data/repositories/coupon_repository.dart';

class CouponController extends GetxController {
  CouponController(this._repository);

  final CouponRepository _repository;

  final isLoading = true.obs;
  final error = Rxn<String>();
  final isMutating = false.obs;
  final coupons = <CouponModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    dev.log('[COUPON/VM] Loading coupons...');
    isLoading.value = true;
    error.value = null;
    try {
      coupons.value = await _repository.fetchCoupons();
      dev.log('[COUPON/VM] ✅ Loaded ${coupons.length} coupons');
    } catch (e) {
      dev.log('[COUPON/VM] ❌ loadCoupons error: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// View truyền vào CouponModel chứa dữ liệu từ form, controller gọi API.
  Future<void> addCoupon(CouponModel request) async {
    dev.log('[COUPON/VM] Creating coupon: ${request.code}');
    isMutating.value = true;
    try {
      final created = await _repository.createCoupon(
        code: request.code,
        discountType: request.discountType,
        discountValue: request.discountValue,
        minOrderValue: request.minOrderValue,
        maxDiscount: request.maxDiscount,
        expiresAt: request.expiresAt,
        usageLimit: request.usageLimit,
      );
      coupons.insert(0, created);
      Get.snackbar(
        'Thành công',
        'Đã tạo mã "${created.code}"',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      dev.log('[COUPON/VM] ✅ Coupon created: ${created.code}');
    } catch (e) {
      dev.log('[COUPON/VM] ❌ addCoupon error: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể tạo mã khuyến mãi: $e',
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
      );
    } finally {
      isMutating.value = false;
    }
  }
}
