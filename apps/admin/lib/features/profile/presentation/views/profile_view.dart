import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/stat_card_widget.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: RefreshIndicator(
        onRefresh: controller.reload,
        color: AppColors.primaryOrange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
            _AdminHeader(),
            const SizedBox(height: 16),
            const _StatsRow(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionLabel('Tài khoản'),
                  const SizedBox(height: 8),
                  AppMenuCard(children: [
                    AppMenuTile(
                      icon: Icons.person_outline,
                      label: 'Thông tin cá nhân',
                      onTap: () => Get.toNamed(AppRoutes.personalInfo),
                    ),
                    const AppMenuDivider(),
                    AppMenuTile(
                      icon: Icons.lock_outline,
                      label: 'Đổi mật khẩu',
                      onTap: () => Get.toNamed(AppRoutes.changePassword),
                    ),
                    const AppMenuDivider(),
                    AppMenuTile(
                      icon: Icons.inbox_outlined,
                      label: 'Hộp thư thông báo',
                      onTap: () => Get.toNamed(AppRoutes.adminNotifications),
                    ),
                    const AppMenuDivider(),
                    AppMenuTile(
                      icon: Icons.notifications_outlined,
                      label: 'Gửi thông báo',
                      onTap: () => Get.toNamed(AppRoutes.notificationPush),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  const AppSectionLabel('Hệ thống'),
                  const SizedBox(height: 8),
                  AppMenuCard(children: [
                    AppMenuTile(
                      icon: Icons.bar_chart_outlined,
                      label: 'Thống kê & Xuất báo cáo',
                      onTap: () => Get.toNamed(AppRoutes.dashboard),
                    ),
                    const AppMenuDivider(),
                    AppMenuTile(
                      icon: Icons.settings_outlined,
                      label: 'Cài đặt cửa hàng',
                      onTap: () => Get.toNamed(AppRoutes.settings),
                    ),
                    const AppMenuDivider(),
                    AppMenuTile(
                      icon: Icons.help_outline,
                      label: 'Trợ giúp & Hỗ trợ',
                      onTap: () => Get.toNamed(AppRoutes.helpSupport),
                    ),
                    const AppMenuDivider(),
                    AppMenuTile(
                      icon: Icons.info_outline,
                      label: 'Về ứng dụng',
                      onTap: () {},
                      trailing:
                          const Text('v1.0.0', style: AppTextStyles.bodySmall),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  AppMenuCard(children: [
                    AppMenuTile(
                      icon: Icons.logout_rounded,
                      label: 'Đăng xuất',
                      iconColor: AppColors.errorRed,
                      labelColor: AppColors.errorRed,
                      onTap: () => _confirmLogout(context),
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất', style: AppTextStyles.h3),
        content: const Text('Bạn chắc chắn muốn đăng xuất?',
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Huỷ',
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: controller.logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

class _AdminHeader extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: MediaQueryData.fromView(View.of(context)).padding.top + 20,
        bottom: 28,
        left: 20,
        right: 20,
      ),
      child: Column(
        children: [
          Obx(() {
            final url = controller.avatarUrl.value;
            return Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.7), width: 2),
              ),
              child: ClipOval(
                child: url != null && url.isNotEmpty
                    ? AppNetworkImage(
                        url: url,
                        fit: BoxFit.cover,
                        errorWidget: const Icon(
                            Icons.admin_panel_settings,
                            size: 38,
                            color: AppColors.white),
                      )
                    : const Icon(Icons.admin_panel_settings,
                        size: 38, color: AppColors.white),
              ),
            );
          }),
          const SizedBox(height: 12),
          Obx(() => Text(controller.adminName.value,
              style: AppTextStyles.h3.copyWith(color: AppColors.white))),
          const SizedBox(height: 4),
          Obx(() => Text(controller.adminEmail.value,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.white.withValues(alpha: 0.85)))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, size: 13, color: AppColors.white),
                SizedBox(width: 5),
                Text('Quản trị viên',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends GetView<ProfileController> {
  const _StatsRow();

  String _fmtRevenue(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        if (controller.isStatsLoading.value) {
          return const Row(
            children: [
              _StatCardSkeleton(),
              SizedBox(width: 10),
              _StatCardSkeleton(),
              SizedBox(width: 10),
              _StatCardSkeleton(),
            ],
          );
        }
        return Row(
          children: [
            StatCardWidget(
              label: 'Đơn hôm nay',
              value: '${controller.todayOrders.value}',
              icon: Icons.receipt_outlined,
              color: AppColors.primaryOrange,
            ),
            const SizedBox(width: 10),
            StatCardWidget(
              label: 'Doanh thu',
              value: _fmtRevenue(controller.todayRevenue.value),
              icon: Icons.trending_up,
              color: AppColors.primaryOrange,
            ),
            const SizedBox(width: 10),
            StatCardWidget(
              label: 'Món ăn',
              value: '${controller.totalFoods.value}',
              icon: Icons.restaurant_menu_outlined,
              color: AppColors.primaryOrange,
            ),
          ],
        );
      }),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Shimmer.fromColors(
        baseColor: AppColors.grey300,
        highlightColor: AppColors.grey100,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
