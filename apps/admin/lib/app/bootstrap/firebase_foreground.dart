import "package:core_network/core_network.dart";
import "package:core_ui/core_ui.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/widgets.dart";
import "package:get/get.dart";

import "../services/auth_service.dart";

/// Xin quyền + đăng ký listener FCM sau frame đầu — không chặn [runApp].
void registerAdminFirebaseForegroundListeners() {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'Thông báo';
      final body = message.notification?.body ?? '';
      Get.snackbar(title, body,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primaryOrange,
          colorText: AppColors.white,
          duration: const Duration(seconds: 5));
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        if (!Get.find<AuthService>().isAuthenticated) return;
        await Get.find<IApiClient>().post(
          '/user/devices/register',
          body: {'fcmToken': newToken, 'deviceType': 'ANDROID'},
        );
      } catch (_) {}
    });
  });
}
