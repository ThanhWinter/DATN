import 'package:core_network/core_network.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/coupons/data/repositories/coupon_repository.dart';
import '../../features/coupons/presentation/controllers/coupon_controller.dart';
import '../../features/customers/data/repositories/customer_repository.dart';
import '../../features/customers/presentation/controllers/customer_controller.dart';
import '../../features/dashboard/data/repositories/statistic_repository.dart';
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
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';

    Get.lazyPut(
      () => AuthController(
        Get.find<AuthRepository>(),
        Get.find<AuthService>(),
      ),
    );

    Get.lazyPut(
      () => StatisticRepository(api, baseUrl),
    );

    Get.lazyPut<OrderRepository>(() => OrderRepository(api));

    Get.lazyPut(
      () => MainController(Get.find<OrderRepository>()),
    );

    Get.lazyPut(() => MenuController(MenuRepository(api)));
    Get.lazyPut(() => OrderController(Get.find<OrderRepository>()));
    Get.lazyPut(() => CouponController(CouponRepository(api)));
    Get.lazyPut(() => CustomerController(CustomerRepository(api)));
    Get.lazyPut(
      () => ProfileController(api, Get.find<StatisticRepository>()),
    );
  }
}
