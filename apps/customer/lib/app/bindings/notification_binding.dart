import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../features/notifications/data/repositories/notification_repository.dart';
import '../../features/notifications/presentation/controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepository(Get.find<IApiClient>()),
    );
    Get.lazyPut<NotificationController>(
      () => NotificationController(Get.find<NotificationRepository>()),
    );
  }
}
