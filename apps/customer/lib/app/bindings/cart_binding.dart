import 'package:get/get.dart';

import '../../features/cart/data/repositories/cart_repository.dart';
import '../../features/cart/presentation/controllers/cart_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartRepository>(() => CartRepository());
    Get.lazyPut<CartController>(
      () => CartController(Get.find<CartRepository>()),
    );
  }
}
