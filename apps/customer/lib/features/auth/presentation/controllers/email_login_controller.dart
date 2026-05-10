import "dart:developer" as dev;

import "package:core_network/core_network.dart";
import "package:core_ui/core_ui.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:get/get.dart";

import "../../../../app/routes/app_routes.dart";
import "../../../../app/services/auth_service.dart";
import "../../data/repositories/auth_repository.dart";
import "../../../profile/data/repositories/profile_repository.dart";

class EmailLoginController extends GetxController {
  EmailLoginController(
      this._authRepository, this._authService, this._profileRepository);

  final AuthRepository _authRepository;
  final AuthService _authService;
  final ProfileRepository _profileRepository;

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final rememberMe = false.obs;
  final emailError = "".obs;
  final passwordError = "".obs;

  /// Callback để View cập nhật TextEditingController khi load được credentials cũ
  void Function(String email, String password)? onSavedCredentialsLoaded;

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final creds = await _authService.getSavedCredentials();
    if (creds['email'] != null && creds['password'] != null) {
      rememberMe.value = true;
      onSavedCredentialsLoaded?.call(creds['email']!, creds['password']!);
    }
  }

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleRememberMe() => rememberMe.toggle();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (!_validate(email, password)) return;

    dev.log("[AUTH/LOGIN] Attempting login for: $email");
    isLoading.value = true;
    try {
      final tokenResponse = await _authRepository.login(
        email: email.trim(),
        password: password,
        rememberMe: rememberMe.value,
      );
      dev.log("[AUTH/LOGIN] ✅ Token received — saving to secure storage");

      await _authService.saveToken(
        tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      );

      // Đồng bộ token vào ApiClient để các API call tiếp theo có auth
      final apiClient = Get.find<IApiClient>();
      apiClient.updateToken(tokenResponse.accessToken);
      apiClient.setRefreshToken(tokenResponse.refreshToken);

      // Đăng ký FCM token (fire-and-forget)
      _registerFcmToken().ignore();

      // Tải và cache profile ngay lập tức để đề phòng server lỗi 500 sau này
      _profileRepository.fetchUser().ignore();

      // Xử lý Ghi nhớ mật khẩu
      if (rememberMe.value) {
        await _authService.saveCredentials(email.trim(), password);
      } else {
        await _authService.clearSavedCredentials();
      }

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      dev.log("[AUTH/LOGIN] ❌ Login failed: $e");
      final message = e is ApiException
          ? _mapErrorCode(e.message)
          : "Đã xảy ra lỗi. Vui lòng thử lại.";
      Get.snackbar(
        "Đăng nhập thất bại",
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

  bool _validate(String email, String password) {
    emailError.value = "";
    passwordError.value = "";

    bool isValid = true;
    if (email.trim().isEmpty) {
      emailError.value = "Vui lòng nhập email";
      isValid = false;
    } else if (!GetUtils.isEmail(email.trim())) {
      emailError.value = "Email không hợp lệ";
      isValid = false;
    }
    if (password.isEmpty) {
      passwordError.value = "Vui lòng nhập mật khẩu";
      isValid = false;
    }
    return isValid;
  }

  String _mapErrorCode(String message) => switch (message) {
        "User not existed!" => "Email chưa được đăng ký trong hệ thống.",
        "Unauthenticated" => "Mật khẩu không chính xác. Vui lòng thử lại.",
        "Unknow exception!" => "Lỗi máy chủ. Vui lòng thử lại sau.",
        _ => "Đăng nhập thất bại. Vui lòng thử lại.",
      };

  Future<void> _registerFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      dev.log("[AUTH/LOGIN] Registering FCM token...");
      await Get.find<IApiClient>().post(
        '/user/devices/register',
        body: {'fcmToken': token, 'deviceType': 'ANDROID'},
      );
      dev.log("[AUTH/LOGIN] ✅ FCM token registered");
    } catch (e) {
      dev.log("[AUTH/LOGIN] ⚠️ FCM registration skipped: $e");
    }
  }
}
