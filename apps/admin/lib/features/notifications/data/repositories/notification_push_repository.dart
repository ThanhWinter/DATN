/// Backend hiện không có endpoint gửi FCM hàng loạt — không gọi mạng.
class NotificationPushRepository {
  Future<void> broadcastToAll({
    required String title,
    required String body,
  }) async {
    throw UnsupportedError(
      'Backend chưa có API gửi thông báo broadcast. '
      'Team BE cần bổ sung endpoint tương ứng trước khi bật tính năng này.',
    );
  }
}
