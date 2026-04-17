import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../main/presentation/controllers/main_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_stats_card.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

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

        final user = controller.user.value;
        if (user == null) return const SizedBox.shrink();

        return CustomScrollView(
          slivers: [
            ProfileHeader(user: user),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileStatsCard(
                      totalOrders: user.totalOrders,
                      totalSaved: user.totalSaved,
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel('Tài khoản'),
                    const SizedBox(height: 8),
                    _buildAccountSection(),
                    const SizedBox(height: 24),
                    const _SectionLabel('Hỗ trợ'),
                    const SizedBox(height: 8),
                    _buildSupportSection(),
                    const SizedBox(height: 24),
                    const _SectionLabel('Cài đặt'),
                    const SizedBox(height: 8),
                    _buildSettingsSection(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAccountSection() {
    return ProfileMenuCard(
      children: [
        ProfileMenuItem(
          icon: Icons.shopping_bag_outlined,
          label: 'Đơn hàng',
          onTap: () => Get.find<MainController>().onTabChanged(2),
        ),
        const ProfileMenuDivider(),
        ProfileMenuItem(
          icon: Icons.local_offer_outlined,
          label: 'Ưu đãi',
          trailing: const ProfileMenuBadge(count: '2'),
          onTap: () => Get.snackbar(
            'Sắp ra mắt',
            'Tính năng đang được phát triển',
            snackPosition: SnackPosition.TOP,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return ProfileMenuCard(
      children: [
        ProfileMenuItem(
          icon: Icons.help_outline_rounded,
          label: 'Câu hỏi thường gặp',
          onTap: () {},
        ),
        const ProfileMenuDivider(),
        ProfileMenuItem(
          icon: Icons.headset_mic_outlined,
          label: 'Liên hệ hỗ trợ',
          onTap: () {},
        ),
        const ProfileMenuDivider(),
        ProfileMenuItem(
          icon: Icons.star_outline_rounded,
          label: 'Đánh giá ứng dụng',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return ProfileMenuCard(
      children: [
        ProfileMenuItem(
          icon: Icons.language_outlined,
          label: 'Ngôn ngữ',
          trailing: Text(
            'Tiếng Việt',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () {},
        ),
        const ProfileMenuDivider(),
        ProfileMenuItem(
          icon: Icons.lock_outline_rounded,
          label: 'Bảo mật & Mật khẩu',
          onTap: () {},
        ),
        const ProfileMenuDivider(),
        ProfileMenuItem(
          icon: Icons.logout_rounded,
          label: 'Đăng xuất',
          onTap: _confirmLogout,
          iconColor: AppColors.errorRed,
          labelColor: AppColors.errorRed,
        ),
      ],
    );
  }

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất', style: AppTextStyles.h3),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất không?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Hủy',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textGrey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: controller.logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}
