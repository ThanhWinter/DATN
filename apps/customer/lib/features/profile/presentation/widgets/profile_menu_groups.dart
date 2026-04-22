import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core_ui/core_ui.dart';
import '../../../main/presentation/controllers/main_controller.dart';
import '../controllers/profile_controller.dart';
import 'profile_menu_section.dart';

class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionLabel('Tài khoản'),
        const SizedBox(height: 8),
        ProfileMenuCard(
          children: [
            ProfileMenuItem(
              svgPath: AppIcons.shoppingBagSvg,
              label: 'Đơn hàng',
              onTap: () => Get.find<MainController>().onTabChanged(2),
            ),
            const ProfileMenuDivider(),
            ProfileMenuItem(
              svgPath: AppIcons.sellSvg,
              label: 'Ưu đãi',
              trailing: const ProfileMenuBadge(count: '2'),
              onTap: () => Get.snackbar(
                'Sắp ra mắt',
                'Tính năng đang được phát triển',
                snackPosition: SnackPosition.TOP,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionLabel('Hỗ trợ'),
        const SizedBox(height: 8),
        ProfileMenuCard(
          children: [
            ProfileMenuItem(
              svgPath: AppIcons.helpSvg,
              label: 'Câu hỏi thường gặp',
              onTap: () {},
            ),
            const ProfileMenuDivider(),
            ProfileMenuItem(
              svgPath: AppIcons.supportSvg,
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
        ),
      ],
    );
  }
}

class SettingsSection extends GetView<ProfileController> {
  const SettingsSection({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionLabel('Cài đặt'),
        const SizedBox(height: 8),
        ProfileMenuCard(
          children: [
            ProfileMenuItem(
              svgPath: AppIcons.languageSvg,
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
              svgPath: AppIcons.lockSvg,
              label: 'Bảo mật & Mật khẩu',
              onTap: () {},
            ),
            const ProfileMenuDivider(),
            ProfileMenuItem(
              svgPath: AppIcons.logoutSvg,
              label: 'Đăng xuất',
              onTap: _confirmLogout,
              iconColor: AppColors.errorRed,
              labelColor: AppColors.errorRed,
            ),
          ],
        ),
      ],
    );
  }
}
