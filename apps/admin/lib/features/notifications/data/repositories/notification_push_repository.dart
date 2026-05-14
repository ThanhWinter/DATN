import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

class NotificationPushRepository {
  NotificationPushRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<void> broadcastToAll({
    required String title,
    required String body,
  }) async {
    dev.log('[NOTIF_PUSH/REPO] Broadcasting: "$title"');
    await _apiClient.post(
      '/admin/notifications/broadcast',
      body: {'title': title, 'body': body},
    );
    dev.log('[NOTIF_PUSH/REPO] ✅ Broadcast sent');
  }
}
