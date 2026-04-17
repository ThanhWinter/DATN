import "package:get/get.dart";

class ForgotPasswordController extends GetxController {
  final isLoading = false.obs;
  final inputError = "".obs;

  Future<void> submit(String email) async {
    inputError.value = "";
    if (email.trim().isEmpty || !GetUtils.isEmail(email)) {
      inputError.value = "Email không hợp lệ";
      return;
    }
    isLoading.value = true;
    try {
      // TODO: Call repository.forgotPassword(email.trim())
      await Future.delayed(const Duration(milliseconds: 500));
      Get.snackbar(
        "Thành công",
        "Mã xác thực đã được gửi đến email của bạn.",
        snackPosition: SnackPosition.TOP,
      );
      // TODO: Get.toNamed(AppRoutes.forgotPasswordOtp, arguments: {'email': email.trim()})
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
