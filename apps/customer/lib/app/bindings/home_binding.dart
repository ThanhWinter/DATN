import 'package:get/get.dart';

import '../../features/home/data/repositories/home_repository.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/notifications/data/repositories/notification_repository.dart';
import '../../features/notifications/presentation/controllers/notification_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeRepository>(() => HomeRepository());
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepository(),
      fenix: true,
    );
    Get.lazyPut<NotificationController>(
      () => NotificationController(Get.find<NotificationRepository>()),
      fenix: true,
    );
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<HomeRepository>()),
    );
  }
}
