import "dart:async";
import "dart:developer" as dev;

import "package:core_network/core_network.dart";
import "package:core_ui/core_ui.dart";
import "package:get/get.dart";

import "../../../../app/routes/app_routes.dart";
import "../../data/repositories/auth_repository.dart";

class OtpController extends GetxController {
  OtpController(this._authRepository);

  final AuthRepository _authRepository;

  final isLoading = false.obs;
  final otpCode = "".obs;
  final email = "".obs;
  late final String _mode;

  // ── Resend OTP state ──────────────────────────────────────────────────
  final isResending = false.obs;
  final resendCountdown = 0.obs;
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      email.value = args['email'] ?? "";
      _mode = args['mode'] ?? 'register';
    } else {
      email.value = args ?? "";
      _mode = 'register';
    }
    dev.log("[AUTH/OTP] Screen init — email: ${email.value}, mode: $_mode");
    _startCountdown();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  String get _otpType =>
      _mode == 'forgot_password' ? 'FORGOT_PASSWORD' : 'REGISTER';

  // =====================================================================
  // VERIFY
  // =====================================================================

  Future<void> verify() async {
    if (otpCode.value.length < 6) {
      Get.snackbar(
        "Mã OTP chưa đủ",
        "Vui lòng nhập đầy đủ 6 chữ số của mã OTP.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.warningYellow,
        colorText: AppColors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (_mode == 'forgot_password') {
      dev.log("[AUTH/OTP] Forgot-password OTP collected — navigating to reset");
      Get.toNamed(
        AppRoutes.resetPassword,
        arguments: {'email': email.value, 'otpCode': otpCode.value},
      );
      return;
    }

    dev.log("[AUTH/OTP] Verifying OTP for ${email.value}");
    isLoading.value = true;
    try {
      await _authRepository.verifyOtp(
        email: email.value,
        otpCode: otpCode.value,
      );

      dev.log(
          "[AUTH/OTP] ✅ OTP verified — account activated for ${email.value}");
      AppSnackbar.success("Thành công", "Tài khoản của bạn đã được kích hoạt!");
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      dev.log("[AUTH/OTP] ❌ Verify failed: $e");
      final message = e is ApiException
          ? _mapErrorCode(e.message)
          : "Xác thực thất bại. Vui lòng thử lại.";
      AppSnackbar.error("Xác thực thất bại", message);
    } finally {
      isLoading.value = false;
    }
  }

  void onOtpChanged(String value) {
    otpCode.value = value;
  }

  // =====================================================================
  // RESEND OTP
  // =====================================================================

  Future<void> resendOtp() async {
    if (resendCountdown.value > 0 || isResending.value) return;

    dev.log("[AUTH/OTP] Resending OTP for ${email.value}, type=$_otpType");
    isResending.value = true;

    try {
      await _authRepository.resendOtp(
        email: email.value,
        type: _otpType,
      );

      dev.log("[AUTH/OTP] ✅ OTP resent successfully");
      AppSnackbar.success("Đã gửi lại mã", "Mã OTP mới đã được gửi đến ${email.value}");
      _startCountdown();
    } catch (e) {
      dev.log("[AUTH/OTP] ❌ Resend failed: $e");
      final message = e is ApiException
          ? _mapResendError(e.message)
          : "Gửi lại mã thất bại. Vui lòng thử lại.";
      AppSnackbar.error("Gửi lại mã thất bại", message);
    } finally {
      isResending.value = false;
    }
  }

  void _startCountdown() {
    resendCountdown.value = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      resendCountdown.value--;
      if (resendCountdown.value <= 0) {
        timer.cancel();
      }
    });
  }

  String _mapErrorCode(String message) => switch (message) {
        "Unauthenticated" => "Mã OTP không chính xác hoặc đã hết hạn.",
        "User not existed!" => "Email không tồn tại trong hệ thống.",
        "Validation failed" => "Mã OTP không hợp lệ. Vui lòng nhập lại.",
        _ => "Xác thực thất bại. Vui lòng thử lại.",
      };

  String _mapResendError(String message) => switch (message) {
        "User not existed!" =>
          "Phiên đăng ký đã hết hạn. Vui lòng quay lại và đăng ký lại.",
        "Validation failed" => "Yêu cầu không hợp lệ. Vui lòng thử lại.",
        _ => "Gửi lại mã thất bại. Vui lòng thử lại sau.",
      };
}
