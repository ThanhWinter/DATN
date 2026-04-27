import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../features/settings/data/repositories/settings_repository.dart';
import '../../features/settings/presentation/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => SettingsController(SettingsRepository(Get.find<IApiClient>())),
    );
  }
}
