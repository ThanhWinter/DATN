class FoodModel {
  FoodModel({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
  });

  final int id;
  final String name;
  final double price;
  final int categoryId;
  final String categoryName;
  final String? description;
  final String? imageUrl;
  bool isAvailable;

  factory FoodModel.fromJson(Map<String, dynamic> json) => FoodModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        categoryId: (json['categoryId'] as num).toInt(),
        categoryName: json['categoryName'] as String? ?? '',
        description: json['description'] as String?,
        imageUrl: json['imageUrl'] as String?,
        isAvailable: json['isAvailable'] as bool? ?? true,
      );

  FoodModel copyWith({
    String? name,
    double? price,
    int? categoryId,
    String? categoryName,
    String? description,
    String? imageUrl,
    bool? isAvailable,
  }) =>
      FoodModel(
        id: id,
        name: name ?? this.name,
        price: price ?? this.price,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        isAvailable: isAvailable ?? this.isAvailable,
      );
}
