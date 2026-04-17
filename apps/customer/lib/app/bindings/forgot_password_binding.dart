import "package:get/get.dart";

import "../../features/auth/presentation/controllers/forgot_password_controller.dart";

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
  }
}
