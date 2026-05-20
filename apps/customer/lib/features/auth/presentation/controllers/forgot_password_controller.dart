import "dart:developer" as dev;

import "package:core_network/core_network.dart";
import "package:core_ui/core_ui.dart";
import "package:get/get.dart";

import "../../../../app/routes/app_routes.dart";
import "../../data/repositories/auth_repository.dart";

class ForgotPasswordController extends GetxController {
  ForgotPasswordController(this._authRepository);

  final AuthRepository _authRepository;

  final isLoading = false.obs;
  final inputError = "".obs;

  Future<void> submit(String email) async {
    inputError.value = "";
    if (email.trim().isEmpty) {
      inputError.value = "Vui lòng nhập địa chỉ email";
      return;
    }
    if (!GetUtils.isEmail(email.trim())) {
      inputError.value = "Email không đúng định dạng. Ví dụ: example@gmail.com";
      return;
    }

    dev.log("[AUTH/FORGOT] Sending OTP to: ${email.trim()}");
    isLoading.value = true;
    try {
      await _authRepository.forgotPassword(email: email.trim());

      dev.log("[AUTH/FORGOT] ✅ OTP sent to ${email.trim()}");
      AppSnackbar.success("Đã gửi mã", "Vui lòng kiểm tra email ${email.trim()} để lấy mã OTP.");
      await Future.delayed(const Duration(milliseconds: 500));
      Get.toNamed(
        AppRoutes.otpVerification,
        arguments: {'email': email.trim(), 'mode': 'forgot_password'},
      );
    } catch (e) {
      dev.log("[AUTH/FORGOT] ❌ Failed to send OTP: $e");
      final message = e is ApiException
          ? _mapErrorCode(e.message)
          : "Không thể gửi mã. Vui lòng thử lại.";
      AppSnackbar.error("Gửi mã thất bại", message);
    } finally {
      isLoading.value = false;
    }
  }

  String _mapErrorCode(String message) => switch (message) {
        "User not existed!" => "Email này chưa được đăng ký trong hệ thống.",
        "Unknow exception!" => "Lỗi máy chủ. Vui lòng thử lại sau.",
        _ => "Không thể gửi mã. Vui lòng thử lại.",
      };
}
