import 'package:get/get.dart';

import '../../features/orders/data/repositories/order_repository.dart';
import '../../features/orders/presentation/controllers/order_detail_controller.dart';

class OrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    // OrderRepository đã được đăng ký fenix: true trong MainBinding,
    // dùng lại thay vì tạo mới để tránh duplicate instance
    Get.lazyPut<OrderDetailController>(
      () => OrderDetailController(Get.find<OrderRepository>()),
    );
  }
}
