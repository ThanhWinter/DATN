import 'package:core_utils/core_utils.dart';

import 'order_item_model.dart';

class OrderModel {
  final String id;
  final DateTime orderDate;
  final double totalAmount;
  final double discountAmount;
  final double shippingFee;
  final String paymentMethod;
  final String? couponCode;
  final String status;
  final String deliveryAddress;
  final String? note;
  final List<String> itemsSummary;
  final List<OrderItemModel> orderItems;

  static const methodCash = 'CASH';
  static const methodZaloPay = 'ZALOPAY';

  OrderModel({
    required this.id,
    required this.orderDate,
    required this.totalAmount,
    this.discountAmount = 0.0,
    this.shippingFee = 0.0,
    this.paymentMethod = methodCash,
    this.couponCode,
    required this.status,
    required this.deliveryAddress,
    this.note,
    required this.itemsSummary,
    this.orderItems = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderDate: parseApiDateTime(json['orderDate']),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num? ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String? ?? methodCash,
      couponCode: json['couponCode'] as String?,
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
