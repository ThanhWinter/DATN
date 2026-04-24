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

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        description: json['description'] as String?,
        imageUrl: json['imageUrl'] as String?,
      );
}
