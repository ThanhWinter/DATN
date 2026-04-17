import "package:get/get.dart";

import "../../../../app/routes/app_routes.dart";

class EmailLoginController extends GetxController {
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final emailError = "".obs;
  final passwordError = "".obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (!_validate(email, password)) return;
    isLoading.value = true;
    try {
      // TODO: Call AuthRepository.login(email, password)
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      Get.snackbar(
        "Đăng nhập thất bại",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate(String email, String password) {
    bool isValid = true;
    emailError.value = "";
    passwordError.value = "";

    if (email.trim().isEmpty || !email.contains("@")) {
      emailError.value = "Email không hợp lệ";
      isValid = false;
    }
    if (password.isEmpty) {
      passwordError.value = "Vui lòng nhập mật khẩu";
      isValid = false;
    }
    return isValid;
  }
}
