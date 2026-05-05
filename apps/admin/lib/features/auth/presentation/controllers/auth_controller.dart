import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:core_ui/core_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/services/auth_service.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  AuthController(this._repository, this._authService);

  final AuthRepository _repository;
  final AuthService _authService;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadSavedCredentials() async {
    final saved = await _authService.getSavedCredentials();
    if (saved['email'] != null) {
      emailCtrl.text = saved['email']!;
      passwordCtrl.text = saved['password'] ?? '';
      rememberMe.value = true;
    }
  }

  Future<void> login() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final tokenResponse = await _repository.login(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
        rememberMe: rememberMe.value,
      );

      await _authService.saveToken(
        tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      );

      // Đồng bộ token vào ApiClient để các API call tiếp theo có auth
      final apiClient = Get.find<IApiClient>();
      apiClient.updateToken(tokenResponse.accessToken);
      apiClient.setRefreshToken(tokenResponse.refreshToken);

      if (rememberMe.value) {
        await _authService.saveCredentials(
          emailCtrl.text.trim(),
          passwordCtrl.text.trim(),
        );
      } else {
        await _authService.clearSavedCredentials();
      }

      dev.log('[AUTH] Admin login success');
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      dev.log('[AUTH] Admin login failed: $e');
      final message = e is ApiException
          ? _mapError(e.message)
          : 'Đăng nhập thất bại. Vui lòng thử lại.';
      errorMessage.value = message;
      Get.snackbar(
        'Đăng nhập thất bại',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) await _repository.unregisterDevice(fcmToken);
      await FirebaseMessaging.instance.unsubscribeFromTopic('admin_orders');
      dev.log('[AUTH] ✅ FCM token unregistered + unsubscribed admin_orders');
    } catch (e) {
      dev.log('[AUTH] ⚠️ FCM unregister skipped: $e');
    }

    try {
      dev.log('[AUTH] Admin logging out...');
      final t = _authService.getToken();
      if (t != null && t.isNotEmpty) {
        await _repository.logout(token: t);
      }
    } catch (e) {
      dev.log('[AUTH] Logout API failed (continuing local logout): $e');
    } finally {
      await _authService.clearAuth();
      // Xoá token cũ khỏi ApiClient để tránh gửi token hết hạn khi đăng nhập lại
      if (Get.isRegistered<IApiClient>()) {
        final apiClient = Get.find<IApiClient>();
        apiClient.updateToken(null);
        apiClient.setRefreshToken(null);
      }
      // Rule 17: Prepend Get.offAllNamed with 500ms delay
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.login);
    }
  }

  String _mapError(String message) => switch (message) {
        'User not existed!' => 'Email không tồn tại trong hệ thống.',
        'Invalid credentials' => 'Email hoặc mật khẩu không chính xác.',
        'Unauthenticated' => 'Email hoặc mật khẩu không chính xác.',
        'Account not verified' => 'Tài khoản chưa được xác thực.',
        _ => 'Đăng nhập thất bại. Vui lòng thử lại.',
      };
}
