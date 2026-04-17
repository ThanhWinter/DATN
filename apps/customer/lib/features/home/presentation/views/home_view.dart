import "package:core_ui/core_ui.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

import "../controllers/home_controller.dart";
import "../widgets/home_category_section.dart";
import "../widgets/home_hero_section.dart";
import "../widgets/home_menu_section.dart";
import "../widgets/home_promo_section.dart";
import "../widgets/home_search_bar.dart";

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          );
        }
        if (controller.error.value != null) {
          return const Center(
            child: Text("Đã có lỗi xảy ra", style: AppTextStyles.bodyLarge),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // expandedHeight(220) - toolbarHeight(56) ≈ 164px
            final collapsed = notification.metrics.pixels > 160;
            if (controller.isAppBarCollapsed.value != collapsed) {
              controller.isAppBarCollapsed.value = collapsed;
            }
            return false;
          },
          child: const CustomScrollView(
            slivers: [
              // ── Hero nhà hàng (sticky app bar) ──────────────────────────
              HomeHeroSection(),

              // ── Thanh tìm kiếm ───────────────────────────────────────────
              SliverToBoxAdapter(child: HomeSearchBar()),

              // ── Banner khuyến mãi ────────────────────────────────────────
              SliverToBoxAdapter(child: HomePromoSection()),

              // ── Bộ lọc danh mục ─────────────────────────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: CategoryHeaderDelegate(
                  child: HomeCategorySection(),
                ),
              ),

              // ── Tiêu đề thực đơn + đếm số lượng ────────────────────────
              SliverToBoxAdapter(child: HomeMenuHeader()),

              // ── Lưới món ăn 2 cột ───────────────────────────────────────
              HomeMenuGrid(),

              SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      }),
    );
  }
}
