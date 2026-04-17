import '../models/notification_model.dart';

class NotificationRepository {
  Future<List<NotificationModel>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
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
        message: 'Giảm 50% cho tất cả đơn hàng Pizza. Nhập mã CUOITUAN50 ngay!',
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
    ];
  }
}
