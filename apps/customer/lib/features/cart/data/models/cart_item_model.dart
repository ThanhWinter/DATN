import '../../../home/data/models/food_option_model.dart';

class CartItemModel {
  final String id; // "${foodId}_${sortedOptionIds}" hoặc "$foodId" nếu không có options
  final int foodId;
  final String name;
  final double price; // base price + sum(selectedOptions.priceAdjustment)
  final int quantity;
  final String? note;
  final String? imageUrl;
  final List<OptionItemModel> selectedOptions;

  CartItemModel({
    required this.id,
    required this.foodId,
    required this.name,
    required this.price,
    required this.quantity,
    this.note,
    this.imageUrl,
    this.selectedOptions = const [],
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      foodId: (json['foodId'] as num).toInt(),
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      note: json['note'] as String?,
      imageUrl: json['imageUrl'] as String?,
      selectedOptions: const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodId': foodId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'note': note,
      'imageUrl': imageUrl,
    };
  }

  CartItemModel copyWith({
    String? id,
    int? foodId,
    String? name,
    double? price,
    int? quantity,
    String? note,
    String? imageUrl,
    List<OptionItemModel>? selectedOptions,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      imageUrl: imageUrl ?? this.imageUrl,
      selectedOptions: selectedOptions ?? this.selectedOptions,
    );
  }

  // Label hiển thị trong cart: "Ít đá, Ít đường"
  String get optionsLabel =>
      selectedOptions.map((o) => o.name).join(', ');
}

// Tạo cart item key duy nhất từ foodId + options đã chọn
String buildCartItemId(int foodId, List<OptionItemModel> options) {
  if (options.isEmpty) return '$foodId';
  final sorted = [...options.map((o) => o.id)]..sort();
  return '${foodId}_${sorted.join('_')}';
}
