import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: SingleChildScrollView(
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
                      onTap: () {},
                    ),
                    const AppMenuDivider(),
                    AppMenuTile(
                      icon: Icons.lock_outline,
                      label: 'Đổi mật khẩu',
                      onTap: () {},
                    ),
                    const AppMenuDivider(),
                    AppMenuTile(
                      icon: Icons.notifications_outlined,
                      label: 'Thông báo',
                      onTap: () {},
                      trailing: const AppMenuBadge(count: '3'),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  const AppSectionLabel('Hệ thống'),
                  const SizedBox(height: 8),
                  AppMenuCard(children: [
                    AppMenuTile(
                      icon: Icons.bar_chart_outlined,
                      label: 'Thống kê doanh thu',
                      onTap: () {},
                      trailing: const _ComingSoonBadge(),
                    ),
                    const AppMenuDivider(),
                    AppMenuTile(
                      icon: Icons.settings_outlined,
                      label: 'Cài đặt cửa hàng',
                      onTap: () {},
                    ),
                    const AppMenuDivider(),
                    AppMenuTile(
                      icon: Icons.help_outline,
                      label: 'Trợ giúp & Hỗ trợ',
                      onTap: () {},
                    ),
                    const AppMenuDivider(),
                    AppMenuTile(
                      icon: Icons.info_outline,
                      label: 'Về ứng dụng',
                      onTap: () {},
                      trailing: const Text('v1.0.0', style: AppTextStyles.bodySmall),
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
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.7), width: 2),
            ),
            child: const Icon(Icons.admin_panel_settings,
                size: 38, color: AppColors.white),
          ),
          const SizedBox(height: 12),
          Obx(() => Text(controller.adminName.value,
              style: AppTextStyles.h3.copyWith(color: AppColors.white))),
          const SizedBox(height: 4),
          Obx(() => Text(controller.adminEmail.value,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.white.withValues(alpha: 0.85)))),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatCard(
              label: 'Đơn hôm nay',
              value: '12',
              icon: Icons.receipt_outlined),
          SizedBox(width: 10),
          _StatCard(
              label: 'Doanh thu',
              value: '1.2M',
              icon: Icons.trending_up),
          SizedBox(width: 10),
          _StatCard(
              label: 'Món ăn',
              value: '9',
              icon: Icons.restaurant_menu_outlined),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryOrange),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.h3
                    .copyWith(color: AppColors.primaryOrange, fontSize: 16)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('Sắp có',
          style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
    );
  }
}
