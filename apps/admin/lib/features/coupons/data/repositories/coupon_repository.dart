import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/coupon_model.dart';

class CouponRepository {
  CouponRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<List<CouponModel>> fetchCoupons({int page = 0, int size = 50}) async {
    dev.log('[COUPON/REPO] Fetching coupons...');
    // API GET /coupons ở Backend trả về List chứ không phải Page (không có field 'content')
    final res = await _apiClient.get('/coupons');
    final list = res['result'] as List<dynamic>? ?? [];
    dev.log('[COUPON/REPO] ✅ Loaded ${list.length} coupons');
    return list
        .map((e) => CouponModel.fromJson(e as Map<String, dynamic>))
        .toList();
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
    dev.log(
        '[COUPON/REPO] Creating coupon: $code | type=$discountType | value=$discountValue');
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
    dev.log(
        '[COUPON/REPO] ✅ Coupon created: id=${created.id} code=${created.code}');
    return created;
  }
}
