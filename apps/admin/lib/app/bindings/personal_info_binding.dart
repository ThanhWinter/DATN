import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../features/profile/data/repositories/profile_admin_repository.dart';
import '../../features/profile/presentation/controllers/personal_info_controller.dart';

class PersonalInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PersonalInfoController(
          ProfileAdminRepository(Get.find<IApiClient>()),
        ));
  }
}
