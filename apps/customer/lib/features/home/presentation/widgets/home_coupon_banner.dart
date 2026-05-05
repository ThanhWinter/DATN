import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../coupons/presentation/controllers/coupon_list_controller.dart';
import '../../../main/presentation/controllers/main_controller.dart';

class HomeCouponBanner extends StatelessWidget {
  const HomeCouponBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count =
          Get.find<CouponListController>().availableCoupons.length;

      return GestureDetector(
        onTap: () => Get.find<MainController>().onTabChanged(2),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryOrange, AppColors.primaryOrangeLight],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryOrange.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_offer_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count > 0
                          ? '$count ưu đãi đang chờ bạn!'
                          : 'Khám phá ưu đãi hôm nay',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      count > 0
                          ? 'Nhấn để xem và áp dụng mã giảm giá'
                          : 'Mã giảm giá cập nhật thường xuyên',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ],
          ),
        ),
      );
    });
  }
}
