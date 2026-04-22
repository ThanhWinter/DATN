import 'package:get/get.dart';

import '../../features/payment/data/repositories/payment_repository.dart';
import '../../features/payment/presentation/controllers/checkout_controller.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentRepository>(() => PaymentRepository());
    Get.lazyPut<CheckoutController>(
      () => CheckoutController(Get.find<PaymentRepository>()),
    );
  }
}
