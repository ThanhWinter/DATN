import 'package:core_network/core_network.dart';

import '../models/order_model.dart';

class OrderCreateRequest {
  final String deliveryAddress;
  final String? note;
  final String? couponCode;
  final List<OrderItemRequest> items;

  const OrderCreateRequest({
    required this.deliveryAddress,
    this.note,
    this.couponCode,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'deliveryAddress': deliveryAddress,
        if (note != null && note!.isNotEmpty) 'note': note,
        if (couponCode != null && couponCode!.isNotEmpty)
          'couponCode': couponCode,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class OrderItemRequest {
  final int foodId;
  final int quantity;
  final List<int> selectedOptionIds;

  const OrderItemRequest({
    required this.foodId,
    required this.quantity,
    this.selectedOptionIds = const [],
  });

  Map<String, dynamic> toJson() => {
        'foodId': foodId,
        'quantity': quantity,
        'selectedOptionIds': selectedOptionIds,
      };
}

class OrderRepository {
  OrderRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<List<OrderModel>> fetchMyOrders() async {
    final response = await _apiClient.get('/orders/my-orders');
    final list = response['result'] as List<dynamic>? ?? [];
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Đếm đơn đang xử lý — một request, không khởi tạo [OrderController].
  static const _badgeActiveStatuses = {
    'PENDING',
    'PAID',
    'PREPARING',
    'DELIVERING',
  };

  Future<int> countActiveOrdersForBadge() async {
    final orders = await fetchMyOrders();
    return orders
        .where((o) => _badgeActiveStatuses.contains(o.status.toUpperCase()))
        .length;
  }

  Future<OrderModel> getOrderById(String id) async {
    final response = await _apiClient.get('/orders/$id');
    final result = response['result'] as Map<String, dynamic>;
    return OrderModel.fromJson(result);
  }

  Future<void> cancelOrder(String id) async {
    await _apiClient.post('/orders/$id/cancel');
  }

  Future<OrderModel> createOrder(OrderCreateRequest request) async {
    final response = await _apiClient.post(
      '/orders',
      body: request.toJson(),
    );
    final result = response['result'] as Map<String, dynamic>;
    return OrderModel.fromJson(result);
  }
}
