import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/coupon_model.dart';

class CouponRepository {
  CouponRepository(this._apiClient);

  final IApiClient _apiClient;

  /// TODO: mock data — chờ backend bổ sung GET /coupons (admin list all coupons).
  Future<List<CouponModel>> fetchCoupons() async {
    await Future.delayed(const Duration(milliseconds: 400));
    dev.log('[COUPON/REPO] ⚠️ fetchCoupons() đang dùng mock data. Backend cần thêm GET /coupons.');
    final now = DateTime.now();
    return [
      CouponModel(
        id: '1',
        code: 'WELCOME10',
        discountType: CouponModel.typePercent,
        discountValue: 10,
        minOrderValue: 50000,
        maxDiscount: 30000,
        expiresAt: now.add(const Duration(days: 30)),
        usageLimit: 100,
        usedCount: 23,
      ),
      CouponModel(
        id: '2',
        code: 'FREESHIP',
        discountType: CouponModel.typeFixed,
        discountValue: 20000,
        minOrderValue: 80000,
        expiresAt: now.add(const Duration(days: 7)),
        usageLimit: 50,
        usedCount: 48,
      ),
      CouponModel(
        id: '3',
        code: 'SUMMER20',
        discountType: CouponModel.typePercent,
        discountValue: 20,
        minOrderValue: 100000,
        maxDiscount: 50000,
        expiresAt: now.add(const Duration(days: 60)),
        usageLimit: 200,
        usedCount: 5,
      ),
      CouponModel(
        id: '4',
        code: 'NEWYEAR50K',
        discountType: CouponModel.typeFixed,
        discountValue: 50000,
        minOrderValue: 150000,
        expiresAt: now.subtract(const Duration(days: 5)),
        usageLimit: 30,
        usedCount: 30,
      ),
    ];
  }

  Future<CouponModel> createCoupon({
    required String code,
    required String discountType,
    required double discountValue,
    double? minOrderValue,
    double? maxDiscount,
    required DateTime expiresAt,
    int? usageLimit,
  }) async {
    dev.log('[COUPON/REPO] Creating coupon: $code | type=$discountType | value=$discountValue');
    final res = await _apiClient.post(
      '/coupons',
      body: {
        'code': code,
        'discountType': discountType,
        'discountValue': discountValue,
        if (minOrderValue != null) 'minOrderValue': minOrderValue,
        if (maxDiscount != null) 'maxDiscount': maxDiscount,
        'expiresAt': expiresAt.toIso8601String(),
        if (usageLimit != null) 'usageLimit': usageLimit,
      },
    );
    final created = CouponModel.fromJson(res['result'] as Map<String, dynamic>);
    dev.log('[COUPON/REPO] ✅ Coupon created: id=${created.id} code=${created.code}');
    return created;
  }
}
