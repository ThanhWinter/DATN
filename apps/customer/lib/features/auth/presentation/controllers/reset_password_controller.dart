import "dart:developer" as dev;

import "package:core_network/core_network.dart";
import "package:core_ui/core_ui.dart";
import "package:get/get.dart";

import "../../../../app/routes/app_routes.dart";
import "../../data/repositories/auth_repository.dart";

// Phải khớp với @Pattern regex trong NewPasswordRequest.java của backend
const _passwordRegex =
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,16}$';

class ResetPasswordController extends GetxController {
  ResetPasswordController(this._authRepository);

  final AuthRepository _authRepository;

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final email = "".obs;

  final passwordError = "".obs;
  final confirmPasswordError = "".obs;

  late final String _otpCode;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map?;
    email.value = args?['email'] ?? "";
    _otpCode = args?['otpCode'] ?? "";
    dev.log("[AUTH/RESET] Screen init — email: ${email.value}");
  }

  void togglePassword() => isPasswordVisible.toggle();
  void toggleConfirmPassword() => isConfirmPasswordVisible.toggle();

  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!_validate(newPassword, confirmPassword)) return;

    dev.log("[AUTH/RESET] Resetting password for: ${email.value}");
    isLoading.value = true;
    try {
      await _authRepository.resetPassword(
        email: email.value,
        otpCode: _otpCode,
        newPassword: newPassword,
      );

      dev.log("[AUTH/RESET] ✅ Password reset success for ${email.value}");
      Get.snackbar(
        "Thành công",
        "Mật khẩu đã được đặt lại. Vui lòng đăng nhập.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        duration: const Duration(seconds: 3),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      dev.log("[AUTH/RESET] ❌ Reset failed: $e");
      final message = e is ApiException
          ? _mapErrorCode(e.message)
          : "Đặt lại mật khẩu thất bại. Vui lòng thử lại.";
      Get.snackbar(
        "Thất bại",
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate(String newPassword, String confirmPassword) {
    passwordError.value = "";
    confirmPasswordError.value = "";

    if (!RegExp(_passwordRegex).hasMatch(newPassword)) {
      passwordError.value = "8–16 ký tự, gồm chữ HOA, thường, số và @\$!%*?&";
      return false;
    }
    if (newPassword != confirmPassword) {
      confirmPasswordError.value = "Mật khẩu không khớp";
      return false;
    }
    return true;
  }

  String _mapErrorCode(String message) => switch (message) {
        "Unauthenticated" => "Mã OTP không chính xác hoặc đã hết hạn.",
        "User not existed!" => "Email không tồn tại trong hệ thống.",
        "Validation failed" => "Thông tin không hợp lệ. Vui lòng kiểm tra lại.",
        "Unknow exception!" => "Lỗi máy chủ. Vui lòng thử lại sau.",
        _ => "Đặt lại mật khẩu thất bại. Vui lòng thử lại.",
      };
}
