import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/home_category_section.dart';
import '../widgets/home_location_header.dart';
import '../widgets/home_popular_section.dart';
import '../widgets/home_promo_section.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onSuccess: () => const Column(
          children: [
            // ── Header vị trí + thanh tìm kiếm (dính trên cùng) ───────────
            HomeLocationHeader(),

            // ── Nội dung cuộn ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),

                    // ── Danh mục thực đơn có hình tròn ────────────────────
                    HomeCategorySection(),

                    SizedBox(height: 8),

                    // ── Banner quảng cáo cố định ───────────────────────────
                    HomePromoSection(),

                    SizedBox(height: 8),

                    // ── Món ăn phổ biến nhất ───────────────────────────────
                    HomePopularSection(),

                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
