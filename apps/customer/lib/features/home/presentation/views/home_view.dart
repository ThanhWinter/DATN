import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/home_category_section.dart';
import '../widgets/home_coupon_banner.dart';
import '../widgets/home_location_header.dart';
import '../widgets/home_popular_section.dart';
import '../widgets/home_promo_section.dart';

class _HomeAdBanner extends StatelessWidget {
  const _HomeAdBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.delivery_dining_rounded,
              color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Giao hàng tận nơi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Đặt hàng ngay — nhanh chóng & tiện lợi',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Đặt ngay',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onSuccess: () => Column(
          children: [
            // ── Header vị trí + thanh tìm kiếm (dính trên cùng) ───────────
            const HomeLocationHeader(),

            // ── Banner cửa hàng đóng cửa ──────────────────────────────────
            Obx(() => controller.isStoreOpen
                ? const SizedBox.shrink()
                : Container(
                    width: double.infinity,
                    color: AppColors.errorRed,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      '🔒 Cửa hàng đang đóng cửa — Đơn hàng sẽ được xử lý khi mở cửa',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.white, fontSize: 13),
                    ),
                  )),

            // ── Nội dung cuộn ─────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadData,
                color: AppColors.primaryOrange,
                child: const SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),

                      // ── Danh mục thực đơn có hình tròn ────────────────────
                      HomeCategorySection(),

                      SizedBox(height: 12),

                      // ── Banner ưu đãi ──────────────────────────────────────
                      HomeCouponBanner(),

                      SizedBox(height: 12),

                      // ── Banner quảng cáo từ server ─────────────────────────
                      HomePromoSection(),

                      SizedBox(height: 8),

                      // ── Banner quảng cáo cố định ───────────────────────────
                      _HomeAdBanner(),

                      SizedBox(height: 8),

                      // ── Món ăn phổ biến nhất ───────────────────────────────
                      HomePopularSection(),

                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
