import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../features/profile/data/repositories/profile_admin_repository.dart';
import '../../features/profile/presentation/controllers/change_password_controller.dart';

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChangePasswordController(
          ProfileAdminRepository(Get.find<IApiClient>()),
        ));
  }
}
