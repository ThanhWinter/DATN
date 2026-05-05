import 'package:core_utils/core_utils.dart';

class CouponModel {
  final String id;
  final String code;
  final String discountType; // "PERCENTAGE" | "FIXED"
  final double discountValue;
  final double? minOrderValue;
  final double? maxDiscount;
  final DateTime expiresAt;
  final bool isActive;
  final int? usageLimit;
  final int usedCount;

  static const typePercent = 'PERCENTAGE';
  static const typeFixed = 'FIXED_AMOUNT';

  const CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderValue,
    this.maxDiscount,
    required this.expiresAt,
    required this.isActive,
    this.usageLimit,
    this.usedCount = 0,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as String,
      code: json['code'] as String,
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      minOrderValue: (json['minOrderValue'] as num?)?.toDouble(),
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
      expiresAt: parseApiDateTime(json['expiresAt']),
      // GET /coupons/{code} có thể không trả isActive; xác thực đã xong trên server.
      isActive: json['isActive'] != false,
      usageLimit: (json['usageLimit'] as num?)?.toInt(),
      usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
    );
  }

  double calculateDiscount(double subtotal) {
    if (!isActive || DateTime.now().isAfter(expiresAt)) return 0;
    if (minOrderValue != null && subtotal < minOrderValue!) return 0;

    final double raw = discountType == typePercent
        ? subtotal * discountValue / 100
        : discountValue;

    final double capped =
        maxDiscount != null ? raw.clamp(0.0, maxDiscount!) : raw;
    return capped.clamp(0.0, subtotal);
  }
}
