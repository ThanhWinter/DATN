// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class OrderModel {
  final String id;
  final DateTime orderDate;
  final double totalAmount;
  final String status; // e.g., 'active', 'completed', 'cancelled'
  final List<String> itemsSummary;

  OrderModel({
    required this.id,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.itemsSummary,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'orderDate': orderDate.millisecondsSinceEpoch,
      'totalAmount': totalAmount,
      'status': status,
      'itemsSummary': itemsSummary,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['orderDate'] as int),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      status: map['status'] as String,
      itemsSummary: List<String>.from((map['itemsSummary'] as List)),
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderModel.fromJson(String source) => OrderModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
