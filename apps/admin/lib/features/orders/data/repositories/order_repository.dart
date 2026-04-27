import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/order_model.dart';

class OrderRepository {
  OrderRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<List<OrderModel>> fetchOrders({int page = 0, int size = 50}) async {
    dev.log('[ORDER/REPO] Fetching orders page=$page...');
    final res = await _apiClient.get(
      '/orders',
      query: {'page': page.toString(), 'size': size.toString()},
    );
    final pageData = res['result'] as Map<String, dynamic>;
    final list = pageData['content'] as List<dynamic>? ?? [];
    dev.log('[ORDER/REPO] ✅ Loaded ${list.length} orders');
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> getOrderDetail(String orderId) async {
    dev.log('[ORDER/REPO] Fetching order detail: $orderId');
    final res = await _apiClient.get('/orders/$orderId');
    final model = OrderModel.fromJson(res['result'] as Map<String, dynamic>);
    dev.log(
        '[ORDER/REPO] ✅ Order detail loaded: ${model.id} status=${model.status}');
    return model;
  }

  /// PATCH /orders/{id}/status?status=NEW_STATUS
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    dev.log('[ORDER/REPO] Updating order $orderId → $newStatus');
    await _apiClient.patch(
      '/orders/$orderId/status',
      query: {'status': newStatus},
    );
    dev.log('[ORDER/REPO] ✅ Order $orderId status updated to $newStatus');
  }
}
