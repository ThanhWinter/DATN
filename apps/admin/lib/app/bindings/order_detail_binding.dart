import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../features/orders/data/repositories/order_repository.dart';
import '../../features/orders/presentation/controllers/order_detail_controller.dart';

class OrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderDetailController>(
      () => OrderDetailController(OrderRepository(Get.find<IApiClient>())),
    );
  }
}
