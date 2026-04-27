import 'package:core_network/core_network.dart';

import '../models/notification_model.dart';

class NotificationRepository {
  NotificationRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<List<NotificationModel>> fetchNotifications() async {
    final response = await _apiClient.get(
      '/user/notifications',
      query: {'page': '0', 'size': '20'},
    );
    final page = response['result'] as Map<String, dynamic>;
    final list = page['content'] as List<dynamic>? ?? [];
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> fetchUnreadCount() async {
    final response =
        await _apiClient.get('/user/notifications/unread-count');
    return (response['result'] as num?)?.toInt() ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.patch('/user/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.patch('/user/notifications/read-all');
  }
}
