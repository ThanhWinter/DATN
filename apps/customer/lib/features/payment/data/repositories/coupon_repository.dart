import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../../../orders/data/models/coupon_model.dart';

class CouponRepository {
  CouponRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<CouponModel> getCoupon(String code) async {
    final response = await _apiClient.get('/coupons/$code');
    final result = response['result'] as Map<String, dynamic>;
    return CouponModel.fromJson(result);
  }

  /// GET /coupons/public-list — backend chỉ trả mã đang áp dụng được (đã lọc HSD / lượt).
  Future<List<CouponModel>> fetchPublicCoupons() async {
    final response = await _apiClient.get('/coupons/public-list');
    final raw = response['result'] as List<dynamic>? ?? [];
    final list = raw
        .map((e) => CouponModel.fromJson(e as Map<String, dynamic>))
        .toList();
    dev.log('[COUPON] public-list → ${list.length} coupons');
    return list;
  }

  /// Alias cho [CouponListController].
  Future<List<CouponModel>> fetchAllCoupons() => fetchPublicCoupons();

  /// Badge tab Ưu đãi — số mã trong public-list (không dùng `.env`).
  Future<int> fetchPublicCouponBadgeCount() async {
    try {
      return (await fetchPublicCoupons()).length;
    } catch (e) {
      dev.log('[COUPON] badge count failed: $e');
      return 0;
    }
  }
}
