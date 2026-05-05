import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../features/coupons/presentation/controllers/coupon_list_controller.dart';
import '../../features/payment/data/repositories/coupon_repository.dart';

class CouponListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CouponListController>(
      () => CouponListController(CouponRepository(Get.find<IApiClient>())),
    );
  }
}
