import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../features/notifications/data/repositories/notification_list_repository.dart';
import '../../features/notifications/presentation/controllers/notification_list_controller.dart';

class NotificationListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationListController>(
      () => NotificationListController(
        NotificationListRepository(Get.find<IApiClient>()),
      ),
    );
  }
}
