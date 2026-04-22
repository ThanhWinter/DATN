import '../models/coupon_model.dart';

class CouponRepository {
  Future<List<CouponModel>> fetchCoupons() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: mock data
    final now = DateTime.now();
    return [
      CouponModel(
        id: '1', code: 'WELCOME10',
        discountType: CouponModel.typePercent, discountValue: 10,
        minOrderValue: 50000, maxDiscount: 30000,
        expiresAt: now.add(const Duration(days: 30)),
        usageLimit: 100, usedCount: 23,
      ),
      CouponModel(
        id: '2', code: 'FREESHIP',
        discountType: CouponModel.typeFixed, discountValue: 20000,
        minOrderValue: 80000,
        expiresAt: now.add(const Duration(days: 7)),
        usageLimit: 50, usedCount: 48,
      ),
      CouponModel(
        id: '3', code: 'SUMMER20',
        discountType: CouponModel.typePercent, discountValue: 20,
        minOrderValue: 100000, maxDiscount: 50000,
        expiresAt: now.add(const Duration(days: 60)),
        usageLimit: 200, usedCount: 5,
      ),
      CouponModel(
        id: '4', code: 'NEWYEAR50K',
        discountType: CouponModel.typeFixed, discountValue: 50000,
        minOrderValue: 150000,
        expiresAt: now.subtract(const Duration(days: 5)),
        usageLimit: 30, usedCount: 30,
      ),
    ];
  }
}
