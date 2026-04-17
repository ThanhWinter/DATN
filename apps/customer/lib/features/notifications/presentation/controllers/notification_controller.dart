import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../data/models/notification_model.dart';

class NotificationController extends GetxController {
  static const _tag = 'NotificationController';

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;

  // RxInt tường minh — KHÔNG dùng computed getter bên trong Obx (Rule 2)
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  // --- Private helpers ---

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> _loadMockData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: mock data
    notifications.assignAll([
      NotificationModel(
        id: '1',
        title: 'Đơn hàng đang đến! 🛵',
        message:
            'Tài xế Nguyễn Văn A đang giao đơn hàng #FH903120 cho bạn. Vui lòng giữ điện thoại.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        type: 'order',
      ),
      NotificationModel(
        id: '2',
        title: 'Bùng nổ Deal Cuối Tuần 🍕',
        message:
            'Giảm 50% cho tất cả đơn hàng Pizza. Nhập mã CUOITUAN50 ngay!',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        isRead: false,
        type: 'promo',
      ),
      NotificationModel(
        id: '3',
        title: 'Giao hàng thành công! ✅',
        message:
            'Đơn hàng #FH882941 của bạn đã được giao thành công. Chúc bạn ngon miệng!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: 'order',
      ),
      NotificationModel(
        id: '4',
        title: 'Cập nhật hệ thống FoodHit',
        message:
            'Chúng tôi vừa ra mắt giao diện hoàn toàn mới cho app Customer. Mời bạn trải nghiệm.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
        type: 'system',
      ),
    ]);

    _updateUnreadCount();
    isLoading.value = false;
    AppLogger.d(
        _tag, 'Loaded ${notifications.length} thông báo, chưa đọc: ${unreadCount.value}');
  }

  // --- Public API ---

  /// Đánh dấu một thông báo là đã đọc, badge giảm 1.
  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
      AppLogger.d(_tag, 'markAsRead: $id | còn chưa đọc: ${unreadCount.value}');
    }
  }

  /// Đánh dấu tất cả là đã đọc, badge về 0.
  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    }
    _updateUnreadCount();
    AppLogger.d(_tag, 'markAllAsRead: badge = ${unreadCount.value}');
  }

  /// Xoá hẳn thông báo, nếu chưa đọc thì badge cũng giảm theo.
  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    _updateUnreadCount();
    AppLogger.d(_tag, 'deleteNotification: $id | còn chưa đọc: ${unreadCount.value}');
  }
}
