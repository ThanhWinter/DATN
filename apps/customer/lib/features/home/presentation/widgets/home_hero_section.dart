import "package:core_ui/core_ui.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

import "../controllers/home_controller.dart";
import "../../../../app/routes/app_routes.dart";

class HomeHeroSection extends GetView<HomeController> {
  const HomeHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
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
              AppNetworkImage(
                url: info.coverImageUrl!,
                fit: BoxFit.cover,
                errorWidget: _orangeGradient(),
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
                                controller.unreadNotificationCount.value;
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
