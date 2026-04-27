class CouponModel {
  final String id;
  final String code;
  final String discountType; // "PERCENTAGE" | "FIXED"
  final double discountValue;
  final double? minOrderValue;
  final double? maxDiscount;
  final DateTime expiresAt;
  final bool isActive;

  const CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderValue,
    this.maxDiscount,
    required this.expiresAt,
    required this.isActive,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as String,
      code: json['code'] as String,
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      minOrderValue: (json['minOrderValue'] as num?)?.toDouble(),
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  double calculateDiscount(double subtotal) {
    if (!isActive || DateTime.now().isAfter(expiresAt)) return 0;
    if (minOrderValue != null && subtotal < minOrderValue!) return 0;

    final double raw = discountType == 'PERCENTAGE'
        ? subtotal * discountValue / 100
        : discountValue;

    final double capped =
        maxDiscount != null ? raw.clamp(0.0, maxDiscount!) : raw;
    return capped.clamp(0.0, subtotal);
  }
}
