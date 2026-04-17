// ── Promo Banner ─────────────────────────────────────────────────────────────
class HomePromoBannerItem {
  final String title;
  final String subtitle;
  final String? imageUrl;

  const HomePromoBannerItem({
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });
}

// ── Category (bộ lọc danh mục món ăn) ────────────────────────────────────────
class CategoryItem {
  final String name;
  final String slug; // "all" | "com" | "bun" | "drink" | "dessert" | ...

  const CategoryItem({required this.name, required this.slug});
}

// ── Thông tin nhà hàng ────────────────────────────────────────────────────────
class RestaurantInfo {
  final String name;
  final double rating;
  final int reviewCount;
  final String deliveryTime;
  final String? coverImageUrl;
  final String? description;

  const RestaurantInfo({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    this.coverImageUrl,
    this.description,
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

  const FoodItemModel({
    required this.id,
    required this.name,
    required this.priceVnd,
    required this.categorySlug,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
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
    );
  }
}
