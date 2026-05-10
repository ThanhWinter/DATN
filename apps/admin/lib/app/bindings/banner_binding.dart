import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../features/banners/presentation/controllers/optimized_banner_controller.dart';
import '../../features/settings/data/repositories/settings_repository.dart';

class BannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OptimizedBannerController>(
      () => OptimizedBannerController(SettingsRepository(Get.find<IApiClient>())),
    );
  }
}
