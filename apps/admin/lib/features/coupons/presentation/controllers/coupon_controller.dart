import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../data/models/coupon_model.dart';
import '../../data/repositories/coupon_repository.dart';

class CouponController extends GetxController {
  CouponController(this._repository);

  final CouponRepository _repository;

  final isLoading = true.obs;
  final error = Rxn<String>();
  final coupons = <CouponModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    isLoading.value = true;
    error.value = null;
    try {
      coupons.value = await _repository.fetchCoupons();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void addCoupon(CouponModel coupon) {
    coupons.insert(0, coupon);
    Get.snackbar('Thành công', 'Đã tạo mã "${coupon.code}"',
        backgroundColor: AppColors.successGreen, colorText: AppColors.white);
  }
}
