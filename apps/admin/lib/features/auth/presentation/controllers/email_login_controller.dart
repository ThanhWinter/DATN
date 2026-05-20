import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:core_ui/core_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/services/auth_service.dart';
import '../../data/repositories/auth_repository.dart';

class EmailLoginController extends GetxController {
  EmailLoginController(this._authRepository, this._authService);

  final AuthRepository _authRepository;
  final AuthService _authService;

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final rememberMe = false.obs;
  final emailError = ''.obs;
  final passwordError = ''.obs;

  /// Callback to View to update TextEditingControllers when old credentials are loaded
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

    dev.log('[AUTH/LOGIN] Admin attempting login for: $email');
    isLoading.value = true;
    try {
      final tokenResponse = await _authRepository.login(
        email: email.trim(),
        password: password,
        rememberMe: rememberMe.value,
      );
      dev.log('[AUTH/LOGIN] ✅ Admin token received — saving to secure storage');

      await _authService.saveToken(
        tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      );

      // Sync token to ApiClient for subsequent authorized calls
      final apiClient = Get.find<IApiClient>();
      apiClient.updateToken(tokenResponse.accessToken);
      apiClient.setRefreshToken(tokenResponse.refreshToken);

      // Đăng ký FCM token + subscribe topic đơn hàng mới (fire-and-forget)
      _registerFcmToken().ignore();
      FirebaseMessaging.instance.subscribeToTopic('admin_orders').ignore();

      // Handle Remember Me
      if (rememberMe.value) {
        await _authService.saveCredentials(email.trim(), password);
      } else {
        await _authService.clearSavedCredentials();
      }

      // Rule 3: Delay before offAllNamed
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      dev.log('[AUTH/LOGIN] ❌ Admin login failed: $e');
      final message = e is ApiException
          ? _mapErrorCode(e.message)
          : 'Đã xảy ra lỗi. Vui lòng thử lại.';
      AppSnackbar.error('Đăng nhập thất bại', message);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validate(String email, String password) {
    emailError.value = '';
    passwordError.value = '';

    bool isValid = true;
    if (email.trim().isEmpty) {
      emailError.value = 'Vui lòng nhập email quản trị';
      isValid = false;
    } else if (!GetUtils.isEmail(email.trim())) {
      emailError.value = 'Email không hợp lệ';
      isValid = false;
    }
    if (password.isEmpty) {
      passwordError.value = 'Vui lòng nhập mật khẩu';
      isValid = false;
    }
    return isValid;
  }

  String _mapErrorCode(String message) => switch (message) {
        'User not existed!' => 'Email quản trị không tồn tại.',
        'Unauthenticated' => 'Mật khẩu không chính xác.',
        'Invalid credentials' => 'Email hoặc mật khẩu không chính xác.',
        _ => 'Đăng nhập thất bại. Vui lòng thử lại.',
      };

  Future<void> _registerFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      dev.log('[AUTH/LOGIN] Registering FCM token...');
      await Get.find<IApiClient>().post(
        '/user/devices/register',
        body: {'fcmToken': token, 'deviceType': 'ANDROID'},
      );
      dev.log('[AUTH/LOGIN] ✅ FCM token registered');
    } catch (e) {
      dev.log('[AUTH/LOGIN] ⚠️ FCM registration skipped: $e');
    }
  }
}
