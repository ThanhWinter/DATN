class OrderItemModel {
  final int id;
  final int foodId;
  final String foodName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final List<String> selectedOptions;

  const OrderItemModel({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.selectedOptions = const [],
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: (json['id'] as num).toInt(),
      foodId: (json['foodId'] as num).toInt(),
      foodName: json['foodName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      selectedOptions: (json['selectedOptions'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
