import 'dart:developer' as dev;

import 'package:core_utils/core_utils.dart';
import 'package:get/get.dart';

import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationController extends GetxController with AutoRefreshMixin {
  final NotificationRepository _repository;

  NotificationController(this._repository);

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshUnreadCount();
    startPolling(const Duration(seconds: 30), _silentPoll);
  }

  Future<void> _silentPoll() async {
    try {
      final newCount = await _repository.fetchUnreadCount();
      final changed = newCount != unreadCount.value;
      unreadCount.value = newCount;
      // Nếu có thông báo mới và màn hình đang hiển thị danh sách thì reload
      if (changed && notifications.isNotEmpty) {
        final list = await _repository.fetchNotifications();
        notifications.assignAll(list);
      }
    } catch (e) {
      dev.log('[NOTIFICATION] ⚠️ silentPoll error (ignored): $e');
    }
  }

  /// Luôn đồng bộ badge với server — tránh lệch local (+1 mãi / không giảm sau đọc).
  Future<void> refreshUnreadCount() async {
    try {
      unreadCount.value = await _repository.fetchUnreadCount();
      dev.log('[NOTIFICATION] ✅ unreadCount (server): ${unreadCount.value}');
    } catch (e) {
      dev.log('[NOTIFICATION] ❌ refreshUnreadCount error: $e');
    }
  }

  // Gọi khi user mở màn hình thông báo
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      notifications.assignAll(await _repository.fetchNotifications());
      await refreshUnreadCount();
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
      await refreshUnreadCount();
      dev.log(
          '[NOTIFICATION] ✅ markAsRead: $id | còn chưa đọc: ${unreadCount.value}');
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
      await refreshUnreadCount();
      dev.log('[NOTIFICATION] ✅ markAllAsRead');
    } catch (e) {
      dev.log('[NOTIFICATION] ❌ markAllAsRead error: $e');
    }
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    refreshUnreadCount().then((_) {
      dev.log(
          '[NOTIFICATION] 🗑️ deleteNotification: $id | còn chưa đọc: ${unreadCount.value}');
    });
  }
}
