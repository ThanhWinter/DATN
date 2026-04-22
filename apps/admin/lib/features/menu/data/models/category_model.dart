class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
}
