import 'package:get/get.dart';

import '../../app/services/auth_service.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/controllers/change_password_controller.dart';

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ChangePasswordController(
        Get.find<ProfileRepository>(),
        Get.find<AuthService>(),
      ),
    );
  }
}
