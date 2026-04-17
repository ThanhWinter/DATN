import 'package:get/get.dart';

import '../../features/cart/data/repositories/cart_repository.dart';
import '../../features/cart/presentation/controllers/cart_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartRepository>(() => CartRepository(), fenix: true);
    Get.lazyPut<CartController>(
      () => CartController(Get.find<CartRepository>()),
      fenix: true,
    );
  }
}
