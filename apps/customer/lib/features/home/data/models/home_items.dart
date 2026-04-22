// ── Promo Banner (hardcoded ad) ───────────────────────────────────────────────
class HomePromoBannerItem {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? badgeText;

  const HomePromoBannerItem({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.badgeText,
  });
}

// ── Category (danh mục thực đơn có hình ảnh) ─────────────────────────────────
class CategoryItem {
  final String name;
  final String slug;
  final String? imageUrl;

  const CategoryItem({
    required this.name,
    required this.slug,
    this.imageUrl,
  });
}

// ── Món ăn ───────────────────────────────────────────────────────────────────
class FoodItemModel {
  final int id;
  final String name;
  final String? description;
  final int priceVnd;
  final String? imageUrl;
  final String categorySlug;
  final bool isAvailable;
  final bool isPopular;

  const FoodItemModel({
    required this.id,
    required this.name,
    required this.priceVnd,
    required this.categorySlug,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
    this.isPopular = false,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      priceVnd: (json['price'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      categorySlug: (json['categorySlug'] ?? 'other').toString(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }
}
