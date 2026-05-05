import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../features/orders/data/repositories/order_repository.dart';
import '../../features/payment/data/repositories/coupon_repository.dart';
import '../../features/payment/data/repositories/payment_repository.dart';
import '../../features/payment/presentation/controllers/checkout_controller.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRepository>(
      () => OrderRepository(Get.find<IApiClient>()),
    );
    Get.lazyPut<CouponRepository>(
      () => CouponRepository(Get.find<IApiClient>()),
    );
    Get.lazyPut<PaymentRepository>(() => PaymentRepository(Get.find<IApiClient>()));
    Get.lazyPut<CheckoutController>(
      () => CheckoutController(
        Get.find<OrderRepository>(),
        Get.find<CouponRepository>(),
        Get.find<PaymentRepository>(),
      ),
    );
  }
}
