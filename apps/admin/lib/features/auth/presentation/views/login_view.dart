import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mintBg,
      body: Stack(
        children: [
          _buildWatermarks(),
          SafeArea(
            child: Column(
              children: [
                _buildHeaderSection(),
                _buildFormCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatermarks() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/login_bg.jpg',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Expanded(
      flex: 5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ManageHit title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Manage',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 44,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.emerald, AppColors.emeraldLight],
                  ).createShader(bounds),
                  child: Text(
                    'Hit',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 44,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              'Hệ thống quản trị nội bộ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTealButton(
            icon: Icons.lock_open_rounded,
            text: 'Đăng nhập Admin',
            onTap: () => Get.toNamed(AppRoutes.emailLogin),
          ),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildOutlineButton(
            icon: Icons.person_add_outlined,
            text: 'Tạo tài khoản Admin',
            onTap: () => Get.toNamed(AppRoutes.register),
          ),
        ],
      ),
    );
  }

  Widget _buildTealButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.emerald,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.emerald.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              text,
              style: AppTextStyles.button.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.white, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              text,
              style: AppTextStyles.button.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.transparent,
                  AppColors.emerald.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.emerald.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.emerald.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            'hoặc',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.emerald.withValues(alpha: 0.3),
                  AppColors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
