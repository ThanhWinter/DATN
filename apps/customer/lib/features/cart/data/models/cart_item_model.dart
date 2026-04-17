class CartItemModel {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? note;
  final String? imageUrl;

  CartItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.note,
    this.imageUrl,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      note: json['note'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'note': note,
      'imageUrl': imageUrl,
    };
  }

  CartItemModel copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? note,
    String? imageUrl,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
