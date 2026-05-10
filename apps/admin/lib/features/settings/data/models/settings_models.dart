class BannerModel {
  final int id;
  final String title;
  final String? imageUrl;
  final String? linkUrl;
  final bool isActive;
  final int displayOrder;

  const BannerModel({
    required this.id,
    required this.title,
    this.imageUrl,
    this.linkUrl,
    this.isActive = true,
    this.displayOrder = 0,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
        linkUrl: json['linkUrl'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      );

  BannerModel copyWith({bool? isActive}) => BannerModel(
        id: id,
        title: title,
        imageUrl: imageUrl,
        linkUrl: linkUrl,
        isActive: isActive ?? this.isActive,
        displayOrder: displayOrder,
      );
}

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

  factory StoreSettingModel.fromJson(Map<String, dynamic> json) =>
      StoreSettingModel(
        storeName: json['storeName'] as String? ?? '',
        hotline: json['hotline'] as String? ?? '',
        isOpen: json['isOpen'] as bool? ?? true,
        baseShippingFee: (json['baseShippingFee'] as num?)?.toDouble() ?? 0.0,
        freeShipThreshold:
            (json['freeShipThreshold'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'hotline': hotline,
        'isOpen': isOpen,
        'baseShippingFee': baseShippingFee,
        'freeShipThreshold': freeShipThreshold,
      };

  StoreSettingModel copyWith({
    String? storeName,
    String? hotline,
    bool? isOpen,
    double? baseShippingFee,
    double? freeShipThreshold,
  }) =>
      StoreSettingModel(
        storeName: storeName ?? this.storeName,
        hotline: hotline ?? this.hotline,
        isOpen: isOpen ?? this.isOpen,
        baseShippingFee: baseShippingFee ?? this.baseShippingFee,
        freeShipThreshold: freeShipThreshold ?? this.freeShipThreshold,
      );
}
