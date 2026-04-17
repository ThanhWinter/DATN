import 'package:get/get.dart';

import '../../features/orders/data/repositories/order_repository.dart';
import '../../features/orders/presentation/controllers/order_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRepository>(() => OrderRepository());
    Get.lazyPut<OrderController>(
      () => OrderController(Get.find<OrderRepository>()),
    );
  }
}
