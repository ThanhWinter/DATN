import 'dart:developer' as dev;

import 'package:get/get.dart';

import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository;

  NotificationController(this._repository);

final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchUnreadCount();
  }

  // Gọi lúc startup — chỉ lấy badge số, không kéo danh sách
  Future<void> _fetchUnreadCount() async {
    try {
      unreadCount.value = await _repository.fetchUnreadCount();
      dev.log('[NOTIFICATION] ✅ unreadCount: ${unreadCount.value}');
    } catch (e) {
      dev.log('[NOTIFICATION] ❌ fetchUnreadCount error: $e');
    }
  }

  // Gọi khi user mở màn hình thông báo
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      notifications.assignAll(await _repository.fetchNotifications());
      dev.log('[NOTIFICATION] ✅ Loaded ${notifications.length} thông báo');
    } catch (e) {
      dev.log('[NOTIFICATION] ❌ loadNotifications error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index == -1 || notifications[index].isRead) return;
    try {
      await _repository.markAsRead(id);
      notifications[index] = notifications[index].copyWith(isRead: true);
      if (unreadCount.value > 0) unreadCount.value--;
      dev.log('[NOTIFICATION] ✅ markAsRead: $id | còn chưa đọc: ${unreadCount.value}');
    } catch (e) {
      dev.log('[NOTIFICATION] ❌ markAsRead error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = notifications[i].copyWith(isRead: true);
        }
      }
      unreadCount.value = 0;
      dev.log('[NOTIFICATION] ✅ markAllAsRead');
    } catch (e) {
      dev.log('[NOTIFICATION] ❌ markAllAsRead error: $e');
    }
  }

  void deleteNotification(String id) {
    final notif = notifications.firstWhereOrNull((n) => n.id == id);
    notifications.removeWhere((n) => n.id == id);
    if (notif != null && !notif.isRead && unreadCount.value > 0) {
      unreadCount.value--;
    }
    dev.log('[NOTIFICATION] 🗑️ deleteNotification: $id | còn chưa đọc: ${unreadCount.value}');
  }
}
