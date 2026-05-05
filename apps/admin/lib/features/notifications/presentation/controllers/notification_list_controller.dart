import 'dart:developer' as dev;

import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../data/models/admin_notification_model.dart';
import '../../data/repositories/notification_list_repository.dart';

class NotificationListController extends GetxController {
  NotificationListController(this._repository);

  final NotificationListRepository _repository;

  final isLoading = true.obs;
  final error = Rxn<String>();
  final isMarkingAll = false.obs;
  final notifications = <AdminNotificationModel>[].obs;
  final hasUnread = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    error.value = null;
    try {
      final list = await _repository.fetchNotifications();
      notifications.assignAll(list);
      hasUnread.value = list.any((n) => !n.isRead);
      dev.log('[NOTIF_LIST/VM] ✅ Loaded ${list.length} notifications');
    } catch (e) {
      dev.log('[NOTIF_LIST/VM] ❌ load: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    if (isMarkingAll.value) return;
    isMarkingAll.value = true;
    try {
      await _repository.markAllAsRead();
      for (var i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
      hasUnread.value = false;
      dev.log('[NOTIF_LIST/VM] ✅ All marked as read');
      Get.snackbar(
        'Đã đọc tất cả',
        'Tất cả thông báo đã được đánh dấu đã đọc.',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      dev.log('[NOTIF_LIST/VM] ❌ markAll: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật thông báo.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isMarkingAll.value = false;
    }
  }

  Future<void> markAsRead(AdminNotificationModel notif) async {
    if (notif.isRead) return;
    try {
      await _repository.markAsRead(notif.id);
      final idx = notifications.indexWhere((n) => n.id == notif.id);
      if (idx != -1) {
        notifications[idx] = notif.copyWith(isRead: true);
        hasUnread.value = notifications.any((n) => !n.isRead);
      }
    } catch (e) {
      dev.log('[NOTIF_LIST/VM] ⚠️ markAsRead ${notif.id}: $e');
    }
  }
}
