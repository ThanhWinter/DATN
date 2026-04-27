import 'order_item_model.dart';

class OrderModel {
  final String id;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final String deliveryAddress;
  final String? note;
  final List<String> itemsSummary;
  final List<OrderItemModel> orderItems;

  OrderModel({
    required this.id,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    this.note,
    required this.itemsSummary,
    this.orderItems = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      note: json['note'] as String?,
      itemsSummary: (json['itemsSummary'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      orderItems: (json['orderItems'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
