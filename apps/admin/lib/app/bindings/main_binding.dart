import 'package:get/get.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/main/presentation/controllers/main_controller.dart';
import '../../features/menu/data/repositories/menu_repository.dart';
import '../../features/menu/presentation/controllers/menu_controller.dart';
import '../../features/orders/data/repositories/order_repository.dart';
import '../../features/orders/presentation/controllers/order_controller.dart';
import '../../features/coupons/data/repositories/coupon_repository.dart';
import '../../features/coupons/presentation/controllers/coupon_controller.dart';
import '../../features/customers/data/repositories/customer_repository.dart';
import '../../features/customers/presentation/controllers/customer_controller.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../services/auth_service.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // AuthController cho ProfileController.logout()
    Get.lazyPut(
      () => AuthController(
        Get.find<AuthRepository>(),
        Get.find<AuthService>(),
      ),
      fenix: true,
    );

    // fenix: true — controllers survive tab switches và không bị GC giữa chừng
    Get.lazyPut(() => MainController(), fenix: true);
    Get.lazyPut(() => MenuController(MenuRepository()), fenix: true);
    Get.lazyPut(() => OrderController(OrderRepository()), fenix: true);
    Get.lazyPut(() => CouponController(CouponRepository()), fenix: true);
    Get.lazyPut(() => CustomerController(CustomerRepository()), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
  }
}
