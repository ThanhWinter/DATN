import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/order_model.dart';

/// Kết quả phân trang (Spring [Page]) cho [GET /orders].
class OrdersPageResult {
  const OrdersPageResult({
    required this.items,
    required this.last,
    required this.pageIndex,
    required this.totalPages,
    required this.totalElements,
  });

  final List<OrderModel> items;
  final bool last;
  final int pageIndex;
  final int totalPages;
  final int totalElements;
}

class OrderRepository {
  OrderRepository(this._apiClient);

  final IApiClient _apiClient;

  /// [status]: một giá trị [OrderStatus] backend; bỏ qua hoặc null = tất cả (admin).
  Future<OrdersPageResult> fetchOrdersPage({
    String? status,
    int page = 0,
    int size = 25,
  }) async {
    dev.log(
        '[ORDER/REPO] Fetching orders status=$status page=$page size=$size');
    final query = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }

    final res = await _apiClient.get('/orders', query: query);
    final pageData = res['result'] as Map<String, dynamic>;
    final list = pageData['content'] as List<dynamic>? ?? [];
    final items = list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final last = pageData['last'] as bool? ?? true;
    final number = (pageData['number'] as num?)?.toInt() ?? page;
    final totalPages = (pageData['totalPages'] as num?)?.toInt() ?? 0;
    final totalElements =
        (pageData['totalElements'] as num?)?.toInt() ?? items.length;

    dev.log(
        '[ORDER/REPO] ✅ page $number/${totalPages > 0 ? totalPages - 1 : 0} — ${items.length} orders (last=$last)');

    return OrdersPageResult(
      items: items,
      last: last,
      pageIndex: number,
      totalPages: totalPages,
      totalElements: totalElements,
    );
  }

  /// Badge tab Đơn hàng: PENDING + PAID + PREPARING + DELIVERING.
  Future<int> fetchPendingBucketBadgeCount() async {
    final results = await Future.wait([
      fetchOrdersPage(status: OrderModel.statusPending, page: 0, size: 1),
      fetchOrdersPage(status: OrderModel.statusPaid, page: 0, size: 1),
      fetchOrdersPage(status: OrderModel.statusPreparing, page: 0, size: 1),
      fetchOrdersPage(status: OrderModel.statusDelivering, page: 0, size: 1),
    ]);
    return results.fold<int>(0, (sum, r) => sum + r.totalElements);
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
