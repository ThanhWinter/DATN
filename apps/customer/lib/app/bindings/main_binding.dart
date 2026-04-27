import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../services/auth_service.dart';

import '../../features/cart/data/repositories/cart_repository.dart';
import '../../features/cart/presentation/controllers/cart_controller.dart';
import '../../features/home/data/repositories/home_repository.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/notifications/data/repositories/notification_repository.dart';
import '../../features/notifications/presentation/controllers/notification_controller.dart';
import '../../features/orders/data/repositories/order_repository.dart';
import '../../features/orders/presentation/controllers/order_controller.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/interactions/data/repositories/interaction_repository.dart';
import '../../features/interactions/presentation/controllers/favorite_controller.dart';
import '../../features/main/presentation/controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController(), fenix: true);

    Get.lazyPut<CartRepository>(() => CartRepository(), fenix: true);
    Get.lazyPut<CartController>(
      () => CartController(Get.find<CartRepository>()),
      fenix: true,
    );

    Get.lazyPut<InteractionRepository>(
      () => InteractionRepository(Get.find<IApiClient>()),
      fenix: true,
    );
    Get.lazyPut<FavoriteController>(
      () => FavoriteController(Get.find<InteractionRepository>()),
      fenix: true,
    );

    Get.lazyPut<NotificationRepository>(
      () => NotificationRepository(Get.find<IApiClient>()),
      fenix: true,
    );
    Get.lazyPut<NotificationController>(
      () => NotificationController(Get.find<NotificationRepository>()),
      fenix: true,
    );

    Get.lazyPut<HomeRepository>(
      () => HomeRepository(Get.find<IApiClient>()),
      fenix: true,
    );
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<HomeRepository>()),
      fenix: true,
    );

    Get.lazyPut<OrderRepository>(
      () => OrderRepository(Get.find<IApiClient>()),
      fenix: true,
    );
    Get.lazyPut<OrderController>(
      () => OrderController(Get.find<OrderRepository>()),
      fenix: true,
    );

    Get.lazyPut<ProfileRepository>(
      () => ProfileRepository(Get.find<IApiClient>(), Get.find<AuthService>()),
      fenix: true,
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<ProfileRepository>(),
        Get.find<AuthRepository>(),
        Get.find<AuthService>(),
      ),
      fenix: true,
    );
  }
}
