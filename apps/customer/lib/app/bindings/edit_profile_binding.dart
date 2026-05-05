import 'package:get/get.dart';

import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/controllers/edit_profile_controller.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileController>(
      () => EditProfileController(
        Get.find<ProfileRepository>(),
      ),
    );
  }
}
