import 'food_option_model.dart';

// ── Promo Banner ──────────────────────────────────────────────────────────────
class HomePromoBannerItem {
  final int id;
  final String title;
  final String? imageUrl;
  final String? linkUrl;
  final bool isActive;

  const HomePromoBannerItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.linkUrl,
    this.isActive = true,
  });

  factory HomePromoBannerItem.fromJson(Map<String, dynamic> json) {
    return HomePromoBannerItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl']?.toString(),
      linkUrl: json['linkUrl']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

// ── Store Setting ─────────────────────────────────────────────────────────────
class StoreSettingModel {
  final String storeName;
  final String hotline;
  final bool isOpen;
  final double baseShippingFee;
  final double freeShipThreshold;

  const StoreSettingModel({
    required this.storeName,
    required this.hotline,
    required this.isOpen,
    required this.baseShippingFee,
    required this.freeShipThreshold,
  });

  factory StoreSettingModel.fromJson(Map<String, dynamic> json) {
    return StoreSettingModel(
      storeName: json['storeName'] as String? ?? '',
      hotline: json['hotline'] as String? ?? '',
      isOpen: json['isOpen'] as bool? ?? true,
      baseShippingFee: (json['baseShippingFee'] as num?)?.toDouble() ?? 0,
      freeShipThreshold: (json['freeShipThreshold'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ── Category ──────────────────────────────────────────────────────────────────
class CategoryItem {
  final int id;
  final String name;
  final String? imageUrl;

  const CategoryItem({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}

// ── Món ăn ───────────────────────────────────────────────────────────────────
class FoodItemModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final int categoryId;
  final String? categoryName;
  final bool isAvailable;
  final List<OptionGroupModel> optionGroups;
  final double? distanceKm;
  final double? deliveryFee;
  final String? deliveryEta;
  final bool hasOffer;
  final String? offerText;

  const FoodItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    this.description,
    this.imageUrl,
    this.categoryName,
    this.isAvailable = true,
    this.optionGroups = const [],
    this.distanceKm,
    this.deliveryFee,
    this.deliveryEta,
    this.hasOffer = false,
    this.offerText,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      categoryName: json['categoryName']?.toString(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      optionGroups: (json['optionGroups'] as List<dynamic>? ?? [])
          .map((e) => OptionGroupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      deliveryEta: json['deliveryEta']?.toString(),
      hasOffer: json['hasOffer'] as bool? ?? false,
      offerText: json['offerText']?.toString(),
    );
  }
}
