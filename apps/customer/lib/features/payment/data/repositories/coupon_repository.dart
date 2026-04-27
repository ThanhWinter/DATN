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
}
