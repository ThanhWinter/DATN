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
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: _watermarkIcon(Icons.eco_rounded, 180),
            ),
            Positioned(
              top: 120,
              left: -30,
              child: _watermarkIcon(Icons.restaurant_menu_rounded, 130),
            ),
            Positioned(
              bottom: 200,
              right: -10,
              child: _watermarkIcon(Icons.local_dining_rounded, 140),
            ),
            Positioned(
              bottom: 80,
              left: -20,
              child: _watermarkIcon(Icons.grass_rounded, 110),
            ),
          ],
        ),
      ),
    );
  }

  Widget _watermarkIcon(IconData icon, double size) {
    return Icon(icon, size: size, color: AppColors.emerald.withValues(alpha: 0.05));
  }

  Widget _buildHeaderSection() {
    return Expanded(
      flex: 5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glass shield icon
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.emerald.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emerald.withValues(alpha: 0.18),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                size: 56,
                color: AppColors.emerald,
              ),
            ),

            const SizedBox(height: 22),

            // FoodHit title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Food',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 40,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.emerald, AppColors.emeraldLight],
                  ).createShader(bounds),
                  child: Text(
                    'Hit',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
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
                color: AppColors.textGrey,
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
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.emerald.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
          gradient: const LinearGradient(
            colors: [AppColors.emeraldDark, AppColors.emerald, AppColors.emeraldLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
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
          border: Border.all(color: AppColors.emerald, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.emerald, size: 20),
            const SizedBox(width: 10),
            Text(
              text,
              style: AppTextStyles.button.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.emerald,
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
              color: AppColors.emerald,
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
