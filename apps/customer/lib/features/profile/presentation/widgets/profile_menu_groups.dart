import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core_ui/core_ui.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../main/presentation/controllers/main_controller.dart';
import '../controllers/profile_controller.dart';
import 'profile_menu_section.dart';

class _CouponBadge extends StatelessWidget {
  const _CouponBadge();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = Get.find<MainController>().availableCouponCount.value;
      if (count == 0) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primaryOrange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$count',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      );
    });
  }
}

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
              icon: Icons.favorite_outline_rounded,
              label: 'Yêu thích',
              onTap: () => Get.toNamed(AppRoutes.favorites),
            ),
            const ProfileMenuDivider(),
            ProfileMenuItem(
              svgPath: AppIcons.sellSvg,
              label: 'Ưu đãi',
              trailing: const _CouponBadge(),
              onTap: () => Get.toNamed(AppRoutes.coupons),
            ),
            const ProfileMenuDivider(),
            ProfileMenuItem(
              icon: Icons.location_on_outlined,
              label: 'Địa chỉ giao hàng',
              onTap: () => Get.toNamed(AppRoutes.addresses),
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
              onTap: () {
                Get.bottomSheet(
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Câu hỏi thường gặp',
                            style: AppTextStyles.h2),
                        const SizedBox(height: 16),
                        const Text('1. Làm sao để hủy đơn hàng?',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text(
                            'Bạn chỉ có thể hủy đơn khi nhà hàng chưa xác nhận. Vui lòng vào chi tiết đơn hàng để thực hiện.',
                            style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 12),
                        const Text('2. Phí giao hàng tính thế nào?',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text(
                            'Phí giao hàng được tính dựa trên khoảng cách từ cửa hàng đến địa chỉ của bạn.',
                            style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Đã hiểu',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const ProfileMenuDivider(),
            ProfileMenuItem(
              svgPath: AppIcons.supportSvg,
              label: 'Liên hệ hỗ trợ',
              onTap: () {
                Get.snackbar(
                  'Liên hệ hỗ trợ',
                  'Vui lòng gọi đến hotline: 1900 1508 hoặc email: support@foodhit.vn',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: AppColors.white,
                  colorText: AppColors.textDark,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                  icon: const Icon(Icons.support_agent_rounded,
                      color: AppColors.primaryOrange),
                );
              },
            ),
            const ProfileMenuDivider(),
            ProfileMenuItem(
              icon: Icons.star_outline_rounded,
              label: 'Đánh giá ứng dụng',
              onTap: () {
                Get.dialog(const _RatingDialog());
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _RatingDialog extends StatefulWidget {
  const _RatingDialog();

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _rating = 0;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      Get.snackbar('Thông báo', 'Vui lòng chọn số sao.', snackPosition: SnackPosition.TOP);
      return;
    }
    if (_rating <= 3 && _reasonController.text.trim().isEmpty) {
      Get.snackbar('Thông báo', 'Vui lòng cho chúng tôi biết lý do để cải thiện nhé.', snackPosition: SnackPosition.TOP);
      return;
    }
    
    Get.back();
    Get.snackbar(
      'Cảm ơn bạn!',
      'Đánh giá của bạn đã được ghi nhận.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.successGreen,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Center(child: Text('Đánh giá ứng dụng', style: AppTextStyles.h3)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Bạn có thích ứng dụng FoodHit không?', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = starIndex),
                child: Icon(
                  starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppColors.accentGold,
                  size: 36,
                ),
              );
            }),
          ),
          if (_rating > 0 && _rating <= 3) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Xin cho biết lý do (bắt buộc)',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Hủy', style: TextStyle(color: AppColors.textGrey)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Gửi đánh giá', style: TextStyle(color: Colors.white)),
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
