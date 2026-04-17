import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository;

  NotificationController(this._repository);

  static const _tag = 'NotificationController';

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      notifications.assignAll(await _repository.fetchNotifications());
      _updateUnreadCount();
      AppLogger.d(_tag,
          'Loaded ${notifications.length} thông báo, chưa đọc: ${unreadCount.value}');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
      AppLogger.d(_tag, 'markAsRead: $id | còn chưa đọc: ${unreadCount.value}');
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    }
    _updateUnreadCount();
    AppLogger.d(_tag, 'markAllAsRead: badge = ${unreadCount.value}');
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    _updateUnreadCount();
    AppLogger.d(_tag,
        'deleteNotification: $id | còn chưa đọc: ${unreadCount.value}');
  }
}
