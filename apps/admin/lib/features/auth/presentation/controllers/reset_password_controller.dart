import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';

class ResetPasswordController extends GetxController {
  ResetPasswordController(this._authRepository);

  final AuthRepository _authRepository;

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final passwordError = ''.obs;
  final confirmPasswordError = ''.obs;

  late final String email;
  late final String otpCode;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    email = args?['email'] as String? ?? '';
    otpCode = args?['otpCode'] as String? ?? '';
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!_validate(newPassword, confirmPassword)) return;

    dev.log('[AUTH/RESET] Resetting password for: $email');
    isLoading.value = true;
    try {
      await _authRepository.resetPassword(
        email: email,
        otpCode: otpCode,
        newPassword: newPassword,
      );

      Get.snackbar(
        'Thành công',
        'Mật khẩu đã được thay đổi. Vui lòng đăng nhập lại.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.accentGold,
        colorText: AppColors.primaryOrangeDark,
      );

      // Rule 3: Delay before offAllNamed
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      dev.log('[AUTH/RESET] ❌ Reset failed: $e');
      final message = e is ApiException
          ? _mapErrorCode(e.message)
          : 'Đã xảy ra lỗi. Vui lòng thử lại.';
      AppSnackbar.error('Lỗi', message);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate(String pass, String confirm) {
    passwordError.value = '';
    confirmPasswordError.value = '';

    bool isValid = true;
    if (pass.length < 6) {
      passwordError.value = 'Mật khẩu phải từ 6 ký tự';
      isValid = false;
    }
    if (confirm != pass) {
      confirmPasswordError.value = 'Mật khẩu xác nhận không khớp';
      isValid = false;
    }
    return isValid;
  }

  String _mapErrorCode(String message) => switch (message) {
        'Invalid OTP' => 'Mã OTP không chính xác hoặc đã hết hạn.',
        _ => 'Đặt lại mật khẩu thất bại. Vui lòng thử lại.',
      };
}
