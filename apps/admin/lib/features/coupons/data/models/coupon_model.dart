import 'package:core_utils/core_utils.dart';

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
  static const typeFixed = 'FIXED';

  bool get isExpired => expiresAt.toUtc().isBefore(DateTime.now().toUtc());

  String get displayValue => discountType == typePercent
      ? '${discountValue.toInt()}%'
      : '${discountValue.toInt()}đ';

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
        id: json['id'] as String? ?? '',
        code: json['code'] as String,
        discountType: json['discountType'] as String,
        discountValue: (json['discountValue'] as num).toDouble(),
        expiresAt: parseApiDateTime(json['expiresAt']),
        minOrderValue: (json['minOrderValue'] as num?)?.toDouble(),
        maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
        usageLimit: (json['usageLimit'] as num?)?.toInt(),
        usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
        isActive: json['isActive'] as bool? ?? true,
      );
}
