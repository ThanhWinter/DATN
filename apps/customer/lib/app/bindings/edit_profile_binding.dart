import 'package:core_network/core_network.dart';
import 'package:get/get.dart';

import '../../features/profile/data/repositories/media_repository.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/controllers/edit_profile_controller.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaRepository>(
      () => MediaRepository(Get.find<IApiClient>()),
    );
    Get.lazyPut<EditProfileController>(
      () => EditProfileController(
        Get.find<ProfileRepository>(),
        Get.find<MediaRepository>(),
      ),
    );
  }
}
