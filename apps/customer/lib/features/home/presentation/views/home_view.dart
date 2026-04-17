import "package:core_ui/core_ui.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

import "../controllers/home_controller.dart";
import "../widgets/category_filter_chip.dart";
import "../widgets/food_item_card.dart";
import "../widgets/promo_banner_card.dart";
import "../../../../app/routes/app_routes.dart";

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
          child: CustomScrollView(
            slivers: [
              // ── Hero nhà hàng (sticky app bar) ──────────────────────────
              _buildRestaurantHeroSliver(),

              // ── Thanh tìm kiếm ───────────────────────────────────────────
              SliverToBoxAdapter(child: _buildSearchBar()),

              // ── Banner khuyến mãi ────────────────────────────────────────
              SliverToBoxAdapter(child: _buildPromoBanner()),

              // ── Bộ lọc danh mục ─────────────────────────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryHeaderDelegate(
                  child: _buildCategoryFilter(),
                ),
              ),

              // ── Tiêu đề thực đơn + đếm số lượng ────────────────────────
              SliverToBoxAdapter(child: _buildMenuHeader()),

              // ── Lưới món ăn 2 cột ───────────────────────────────────────
              _buildFoodGrid(),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedTabIndex.value,
          onTap: controller.onTabChanged,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primaryOrange,
          unselectedItemColor: AppColors.textGrey,
          selectedLabelStyle: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: AppTextStyles.bodySmall.copyWith(fontSize: 11),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Thực đơn",
            ),
            BottomNavigationBarItem(
              icon: Obx(() {
                final count = controller.cartItemCount;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    if (count > 0)
                      Positioned(
                        right: -6,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.errorRed,
                            shape: BoxShape.circle,
                          ),
                          constraints:
                              const BoxConstraints(minWidth: 16, minHeight: 16),
                          alignment: Alignment.center,
                          child: Text(
                            count > 99 ? "99+" : "$count",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
              label: "Giỏ hàng",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              label: "Đơn hàng",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: "Tôi",
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── Sections ──────────────────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildRestaurantHeroSliver() {
    final info = controller.restaurantInfo.value;
    if (info == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primaryOrangeDark,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Ảnh bìa hoặc gradient
            if (info.coverImageUrl != null)
              Image.network(
                info.coverImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _orangeGradient(),
              )
            else
              _orangeGradient(),

            // Overlay gradient từ dưới
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.black.withValues(alpha: 0.1),
                    AppColors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),

            // Nội dung trên hero
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TopBar bên trong hero
                    Row(
                      children: [
                        Text(
                          "FoodHit",
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        // Avatar user
                        Obx(
                          () => Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              controller.userInitial.value,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Nút thông báo
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.notifications),
                          child: Obx(() {
                            final unreadCount =
                                controller.unreadNotificationCount;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_outlined,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.errorRed,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                          minWidth: 16, minHeight: 16),
                                      alignment: Alignment.center,
                                      child: Text(
                                        unreadCount > 9 ? "9+" : "$unreadCount",
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),

                    // Thông tin nhà hàng ở phần dưới hero
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.name,
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (info.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            info.description!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // Đánh giá
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: AppColors.black,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    "${info.rating} (${info.reviewCount})",
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Thời gian giao hàng
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.white.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 13,
                                    color:
                                        AppColors.white.withValues(alpha: 0.9),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    info.deliveryTime,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Chỉ hiện tên khi SliverAppBar đã thu gọn
      title: Obx(
        () => controller.isAppBarCollapsed.value
            ? Text(
                info.name,
                style: AppTextStyles.h3.copyWith(color: AppColors.white),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.grey400, size: 22),
            const SizedBox(width: 12),
            Text(
              "Tìm món ăn bạn muốn...",
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.grey400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Obx(() {
      final banner = controller.promoBanner.value;
      if (banner == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: SizedBox(
          height: 130,
          child: PromoBannerCard(
            item: banner,
            onTap: () => Get.snackbar(
              "Khuyến mãi",
              banner.title,
              snackPosition: SnackPosition.TOP,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCategoryFilter() {
    return Container(
      color: AppColors.grey100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Obx(() {
        // Đọc giá trị synchronously để GetX đăng ký callback
        final currentSlug = controller.selectedCategorySlug.value;
        return SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: controller.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = controller.categories[index];
              return CategoryFilterChip(
                item: cat,
                isSelected: currentSlug == cat.slug,
                onTap: () => controller.selectCategory(cat.slug),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildMenuHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Obx(
        () => Row(
          children: [
            const Text("Thực đơn", style: AppTextStyles.h3),
            const SizedBox(width: 8),
            Text(
              "(${controller.filteredFoodItems.length} món)",
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodGrid() {
    return Obx(() {
      if (controller.filteredFoodItems.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.no_food_outlined,
                      size: 48, color: AppColors.grey300),
                  SizedBox(height: 12),
                  Text(
                    "Không có món nào trong danh mục này",
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = controller.filteredFoodItems[index];
              return FoodItemCard(
                item: item,
                onAdd:
                    item.isAvailable ? () => controller.addToCart(item) : null,
                onTap: () {},
              );
            },
            childCount: controller.filteredFoodItems.length,
          ),
        ),
      );
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _orangeGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryOrangeDark,
            AppColors.primaryOrange,
            AppColors.primaryOrangeLight,
          ],
        ),
      ),
    );
  }
}

// ── Delegate cho sticky category bar ──────────────────────────────────────────
class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _CategoryHeaderDelegate({required this.child});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      elevation: shrinkOffset > 0 ? 2 : 0,
      color: AppColors.grey100,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_CategoryHeaderDelegate oldDelegate) =>
      oldDelegate.child != child;
}
