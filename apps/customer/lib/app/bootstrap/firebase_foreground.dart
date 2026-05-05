import "package:core_network/core_network.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/widgets.dart";
import "package:get/get.dart";

import "../../features/notifications/presentation/controllers/notification_controller.dart";

/// Xin quyền + đăng ký listener FCM sau frame đầu — không chặn [runApp],
/// login / splash hiển thị nhanh hơn so với await permission trước [runApp].
void registerCustomerFirebaseForegroundListeners() {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.subscribeToTopic('customer_promotions');

    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'Thông báo';
      final body = message.notification?.body ?? '';
      Get.snackbar(title, body,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4));

      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().refreshUnreadCount();
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      try {
        Get.find<IApiClient>().post(
          '/user/devices/register',
          body: {'fcmToken': newToken, 'deviceType': 'ANDROID'},
        );
      } catch (_) {}
    });
  });
}
