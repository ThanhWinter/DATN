import 'package:get/get.dart';

import '../../features/notifications/data/repositories/notification_push_repository.dart';
import '../../features/notifications/presentation/controllers/notification_push_controller.dart';

class NotificationPushBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => NotificationPushController(
        NotificationPushRepository(),
      ),
    );
  }
}
