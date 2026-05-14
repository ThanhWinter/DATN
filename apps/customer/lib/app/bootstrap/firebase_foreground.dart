import "dart:developer" as dev;

import "package:core_network/core_network.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/widgets.dart";
import "package:get/get.dart";

import "../../features/notifications/presentation/controllers/notification_controller.dart";
import "../../features/orders/presentation/controllers/order_controller.dart";
import "../../features/orders/presentation/controllers/order_detail_controller.dart";

/// Xóa cache của đơn hàng + danh sách đơn, sau đó cập nhật các controller
/// đang active. Gọi cả khi app foreground lẫn khi user tap notification từ
/// background — đảm bảo không bao giờ hiển thị data cũ từ cache.
void _handleOrderFcm(String orderId) {
  // Bắt buộc xóa cache trước khi reload — không xóa thì GET vẫn trả data cũ
  // dù TTL chưa hết (admin đổi trạng thái không tự xóa cache customer app)
  apiCache.invalidate('GET_/orders/${orderId}_');
  apiCache.invalidate('GET_/orders/my-orders_');
  dev.log('[FCM] Cache invalidated for order $orderId');

  if (Get.isRegistered<OrderController>()) {
    Get.find<OrderController>().loadOrders();
  }
  if (Get.isRegistered<OrderDetailController>()) {
    final ctrl = Get.find<OrderDetailController>();
    if (ctrl.order.value?.id == orderId) {
      ctrl.loadOrder(orderId);
    }
  }
}

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

    // App ở foreground — hiện snackbar và cập nhật UI ngay lập tức
    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'Thông báo';
      final body = message.notification?.body ?? '';
      Get.snackbar(title, body,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4));

      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().refreshUnreadCount();
      }

      final orderId = message.data['orderId'] as String?;
      if (orderId != null) _handleOrderFcm(orderId);
    });

    // App ở background/bị kill — user tap vào notification để mở app.
    // Lúc này cache chưa bị xóa nên phải invalidate trước khi controller load data.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().refreshUnreadCount();
      }
      final orderId = message.data['orderId'] as String?;
      if (orderId != null) _handleOrderFcm(orderId);
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
