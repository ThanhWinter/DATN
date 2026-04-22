class CouponModel {
  CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.expiresAt,
    this.minOrderValue,
    this.maxDiscount,
    this.usageLimit,
    this.usedCount = 0,
    this.isActive = true,
  });

  final String id;
  final String code;
  final String discountType;
  final double discountValue;
  final DateTime expiresAt;
  final double? minOrderValue;
  final double? maxDiscount;
  final int? usageLimit;
  final int usedCount;
  bool isActive;

  static const typePercent = 'PERCENTAGE';
  static const typeFixed = 'FIXED_AMOUNT';

  bool get isExpired => expiresAt.isBefore(DateTime.now());

  String get displayValue => discountType == typePercent
      ? '${discountValue.toInt()}%'
      : '${discountValue.toInt()}đ';
}
