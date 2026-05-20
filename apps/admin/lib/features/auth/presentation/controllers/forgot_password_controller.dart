import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController(this._authRepository);

  final AuthRepository _authRepository;

  final isLoading = false.obs;
  final emailError = ''.obs;

  Future<void> sendOtp(String email) async {
    if (!_validate(email)) return;

    dev.log('[AUTH/FORGOT] Sending OTP for: $email');
    isLoading.value = true;
    try {
      await _authRepository.forgotPassword(email: email.trim());

      Get.snackbar(
        'Thành công',
        'Mã OTP đã được gửi đến email của bạn.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.accentGold,
        colorText: AppColors.primaryOrangeDark,
      );

      // Navigate to OTP screen for forgot password
      Get.toNamed(AppRoutes.otp, arguments: {
        'email': email.trim(),
        'type': 'FORGOT_PASSWORD',
      });
    } catch (e) {
      dev.log('[AUTH/FORGOT] ❌ Failed to send OTP: $e');
      final message = e is ApiException
          ? _mapErrorCode(e.message)
          : 'Đã xảy ra lỗi. Vui lòng thử lại.';
      AppSnackbar.error('Lỗi', message);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate(String email) {
    emailError.value = '';
    if (email.trim().isEmpty) {
      emailError.value = 'Vui lòng nhập email';
      return false;
    } else if (!GetUtils.isEmail(email.trim())) {
      emailError.value = 'Email không hợp lệ';
      return false;
    }
    return true;
  }

  String _mapErrorCode(String message) => switch (message) {
        'User not existed!' => 'Email chưa được đăng ký trong hệ thống.',
        _ => 'Yêu cầu thất bại. Vui lòng thử lại.',
      };
}
