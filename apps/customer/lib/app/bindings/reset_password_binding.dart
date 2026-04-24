import "package:get/get.dart";

import "../../features/auth/data/repositories/auth_repository.dart";
import "../../features/auth/presentation/controllers/reset_password_controller.dart";

class ResetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResetPasswordController>(
      () => ResetPasswordController(Get.find<AuthRepository>()),
    );
  }
}
