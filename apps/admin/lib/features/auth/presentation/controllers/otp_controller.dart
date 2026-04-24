import 'dart:async';
import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';

class OtpController extends GetxController {
  OtpController(this._repository);

  final AuthRepository _repository;

  final otpTextCtrl = TextEditingController();
  final email = ''.obs;
  final otpType = 'REGISTER'.obs; // 'REGISTER' or 'FORGOT_PASSWORD'
  final isLoading = false.obs;
  final isResending = false.obs;
  final countdown = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      email.value = args['email'] ?? '';
      otpType.value = args['type'] ?? 'REGISTER';
    }
    dev.log('[OTP] Screen init — email: ${email.value}, type: ${otpType.value}');
    _startCountdown();
  }

  @override
  void onClose() {
    otpTextCtrl.dispose();
    _timer?.cancel();
    super.onClose();
  }

  Future<void> verify() async {
    final code = otpTextCtrl.text.trim();
    if (code.length < 6) {
      Get.snackbar(
        'Mã OTP chưa đủ',
        'Vui lòng nhập đầy đủ 6 chữ số.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.warningYellow,
        colorText: AppColors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      if (otpType.value == 'REGISTER') {
        await _repository.verifyOtp(
          email: email.value,
          otpCode: code,
        );

        dev.log('[OTP] ✅ Verified Registration — ${email.value}');
        Get.snackbar(
          'Thành công',
          'Tài khoản đã được kích hoạt. Vui lòng đăng nhập.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.successGreen,
          colorText: AppColors.white,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(AppRoutes.login);
      } else {
        // FORGOT_PASSWORD flow - just proceed to Reset Password view
        // The verification will happen at resetPassword API call, or we could verify here if there was a separate verify-forgot-otp endpoint.
        // Backend seems to use otpCode inside reset-password call.
        dev.log('[OTP] ✅ Proceeding to Reset Password — ${email.value}');
        await Future.delayed(const Duration(milliseconds: 300));
        Get.toNamed(AppRoutes.resetPassword, arguments: {
          'email': email.value,
          'otpCode': code,
        });
      }
    } catch (e) {
      dev.log('[OTP] ❌ Verify failed: $e');
      final message = e is ApiException
          ? _mapError(e.message)
          : 'Xác thực thất bại. Vui lòng thử lại.';
      Get.snackbar(
        'Xác thực thất bại',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (countdown.value > 0 || isResending.value) return;

    isResending.value = true;
    try {
      await _repository.resendOtp(email: email.value, type: otpType.value);
      dev.log('[OTP] ✅ Resent ($otpType) to ${email.value}');
      Get.snackbar(
        'Đã gửi lại mã',
        'Mã OTP mới đã được gửi đến ${email.value}.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      _startCountdown();
    } catch (e) {
      dev.log('[OTP] ❌ Resend failed: $e');
      Get.snackbar(
        'Gửi lại thất bại',
        'Vui lòng thử lại sau.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
      );
    } finally {
      isResending.value = false;
    }
  }

  void _startCountdown() {
    countdown.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      countdown.value--;
      if (countdown.value <= 0) t.cancel();
    });
  }

  String _mapError(String message) => switch (message) {
        'Unauthenticated' => 'Mã OTP không chính xác hoặc đã hết hạn.',
        'User not existed!' => 'Email không tồn tại trong hệ thống.',
        'INVALID_OTP' => 'Mã OTP không hợp lệ.',
        _ => 'Xác thực thất bại. Vui lòng thử lại.',
      };
}
