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
}
