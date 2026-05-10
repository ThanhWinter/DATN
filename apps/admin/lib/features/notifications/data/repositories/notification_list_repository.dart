import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/admin_notification_model.dart';

class NotificationListRepository {
  NotificationListRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<List<AdminNotificationModel>> fetchNotifications({
    int page = 0,
    int size = 20,
  }) async {
    dev.log('[NOTIF_LIST/REPO] Fetching notifications page=$page...');
    final res =
        await _apiClient.get('/user/notifications?page=$page&size=$size');
    final content = (res['result']['content'] as List<dynamic>? ?? []);
    final list = content
        .map((e) => AdminNotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    dev.log('[NOTIF_LIST/REPO] ✅ Loaded ${list.length} notifications');
    return list;
  }

  Future<void> markAllAsRead() async {
    dev.log('[NOTIF_LIST/REPO] Marking all as read...');
    await _apiClient.patch('/user/notifications/read-all');
    dev.log('[NOTIF_LIST/REPO] ✅ All marked as read');
  }

  Future<void> markAsRead(int id) async {
    await _apiClient.patch('/user/notifications/$id/read');
  }
}
