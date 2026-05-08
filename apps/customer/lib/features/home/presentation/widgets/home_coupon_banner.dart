import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../coupons/presentation/controllers/coupon_list_controller.dart';
import '../../../main/presentation/controllers/main_controller.dart';

/// Thanh nhỏ hiển thị số ưu đãi khả dụng — chỉ xuất hiện khi có coupon.
class HomeCouponBanner extends StatelessWidget {
  const HomeCouponBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = Get.find<CouponListController>().availableCoupons.length;
      if (count == 0) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.find<MainController>().onTabChanged(2),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primaryOrange.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Text(
                '$count ưu đãi đang chờ bạn',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryOrange,
                ),
              ),
              const Spacer(),
              const Text(
                'Xem ngay',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.primaryOrange,
              ),
            ],
          ),
        ),
      );
    });
  }
}
