import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../data/models/profile_models.dart';
import '../controllers/profile_controller.dart';

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
            _buildHeader(user),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsRow(user),
                    const SizedBox(height: 24),
                    _buildSectionLabel('Tài khoản'),
                    const SizedBox(height: 8),
                    _buildAccountSection(),
                    const SizedBox(height: 24),
                    _buildSectionLabel('Hỗ trợ'),
                    const SizedBox(height: 8),
                    _buildSupportSection(),
                    const SizedBox(height: 24),
                    _buildSectionLabel('Cài đặt'),
                    const SizedBox(height: 8),
                    _buildSettingsSection(),
                    const SizedBox(height: 24),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(UserModel user) {
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      backgroundColor: AppColors.primaryOrangeDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white),
        onPressed: Get.back,
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatar(user),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.fullName,
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined,
                                size: 13,
                                color: AppColors.white.withValues(alpha: 0.8)),
                            const SizedBox(width: 5),
                            Text(
                              user.phone,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.mail_outline_rounded,
                                size: 13,
                                color: AppColors.white.withValues(alpha: 0.8)),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                user.email,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _showEditProfileSheet(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(UserModel user) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.25),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.7),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        user.initials,
        style: AppTextStyles.h2.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  Widget _buildStatsRow(UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
          _buildStatItem(
            icon: Icons.receipt_long_outlined,
            value: '${user.totalOrders}',
            label: 'Đơn hàng',
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: Icons.local_offer_outlined,
            value: '${user.totalSaved.toVnd()} ₫',
            label: 'Tiết kiệm được',
            iconColor: AppColors.successGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    Color iconColor = AppColors.primaryOrange,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 48, color: AppColors.grey300);
  }

  // ── Sections ──────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildCard([
      _buildMenuItem(
        icon: Icons.shopping_bag_outlined,
        label: 'Đơn hàng',
        onTap: () => Get.toNamed(AppRoutes.orders),
      ),
      _buildDivider(),
      _buildMenuItem(
        icon: Icons.local_offer_outlined,
        label: 'Ưu đãi',
        trailing: _buildBadge('2'),
        onTap: () => Get.snackbar(
          'Sắp ra mắt',
          'Tính năng đang được phát triển',
          snackPosition: SnackPosition.TOP,
        ),
      ),
    ]);
  }

  Widget _buildSettingsSection() {
    return _buildCard([
      _buildMenuItem(
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
      _buildDivider(),
      _buildMenuItem(
        icon: Icons.lock_outline_rounded,
        label: 'Bảo mật & Mật khẩu',
        onTap: () {},
      ),
      _buildDivider(),
      _buildMenuItem(
        icon: Icons.logout_rounded,
        label: 'Đăng xuất',
        onTap: _confirmLogout,
        iconColor: AppColors.errorRed,
        labelColor: AppColors.errorRed,
      ),
    ]);
  }

  Widget _buildSupportSection() {
    return _buildCard([
      _buildMenuItem(
        icon: Icons.help_outline_rounded,
        label: 'Câu hỏi thường gặp',
        onTap: () {},
      ),
      _buildDivider(),
      _buildMenuItem(
        icon: Icons.headset_mic_outlined,
        label: 'Liên hệ hỗ trợ',
        onTap: () {},
      ),
      _buildDivider(),
      _buildMenuItem(
        icon: Icons.star_outline_rounded,
        label: 'Đánh giá ứng dụng',
        onTap: () {},
      ),
    ]);
  }

  // ── Primitives ────────────────────────────────────────────────────────────

  Widget _buildCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Color? labelColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor != null
                    ? iconColor.withValues(alpha: 0.1)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.textGrey, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: labelColor,
                ),
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey400,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppColors.grey300),
    );
  }

  Widget _buildBadge(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  // ── Dialogs / Sheets ──────────────────────────────────────────────────────

  void _showEditProfileSheet() {
    final user = controller.user.value;
    if (user == null) return;

    final nameController = TextEditingController(text: user.fullName);
    final phoneController = TextEditingController(text: user.phone);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Chỉnh sửa hồ sơ', style: AppTextStyles.h3),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryOrange),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryOrange),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.snackbar(
                    'Đã lưu',
                    'Thông tin hồ sơ đã được cập nhật',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: AppColors.primaryOrange,
                    colorText: AppColors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lưu thay đổi',
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
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
