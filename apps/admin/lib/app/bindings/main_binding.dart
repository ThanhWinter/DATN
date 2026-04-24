import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/coupons/data/repositories/coupon_repository.dart';
import '../../features/coupons/presentation/controllers/coupon_controller.dart';
import '../../features/customers/data/repositories/customer_repository.dart';
import '../../features/customers/presentation/controllers/customer_controller.dart';
import '../../features/main/presentation/controllers/main_controller.dart';
import '../../features/menu/data/repositories/menu_repository.dart';
import '../../features/menu/presentation/controllers/menu_controller.dart';
import '../../features/orders/data/repositories/order_repository.dart';
import '../../features/orders/presentation/controllers/order_controller.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../services/auth_service.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    final api = Get.find<IApiClient>();

    // AuthController — cần cho ProfileController.logout()
    Get.lazyPut(
      () => AuthController(
        Get.find<AuthRepository>(),
        Get.find<AuthService>(),
      ),
      fenix: true,
    );

    Get.lazyPut(() => MainController(), fenix: true);
    Get.lazyPut(() => MenuController(MenuRepository(api)), fenix: true);
    Get.lazyPut(() => OrderController(OrderRepository(api)), fenix: true);
    Get.lazyPut(() => CouponController(CouponRepository(api)), fenix: true);
    Get.lazyPut(() => CustomerController(CustomerRepository(api)), fenix: true);
    Get.lazyPut(() => ProfileController(api), fenix: true);
  }
}
