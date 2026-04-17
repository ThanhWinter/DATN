import "package:core_ui/core_ui.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

import "../../../../app/routes/app_routes.dart";
import "../controllers/auth_controller.dart";

/// Màn hình đăng nhập Customer — thiết kế gradient cam
/// lấy cảm hứng từ shipper_app login của fo_mobile.
class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background Gradient ─────────────────────────────────
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryOrangeDark,
                  AppColors.primaryOrange,
                  AppColors.primaryOrangeLight,
                ],
              ),
            ),
          ),

          // ── Nội dung chính ──────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top: Logo / Tagline
                _buildHeaderSection(),

                // Bottom: Login Form + Buttons
                _buildFormSection(),
              ],
            ),
          ),

          // ── Loading Overlay ────────────────────────────────────
          Obx(() => controller.isLoading.value
              ? Container(
                  color: AppColors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 3,
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── Extracted sections ─────────────────────────────────────────────────
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildHeaderSection() {
    return Expanded(
      flex: 5,
      child: Stack(
        children: [
          // Logo "FoodHit"
          Positioned(
            left: 24,
            right: 24,
            top: 0,
            bottom: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Food",
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 48,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                      shadows: [
                        Shadow(
                          color: AppColors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Hit",
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 48,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentGold,
                      shadows: [
                        Shadow(
                          color: AppColors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tagline
          Positioned(
            left: 24,
            right: 24,
            bottom: 20,
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.h1.copyWith(
                  fontSize: 30,
                  height: 1.3,
                  color: AppColors.white,
                  shadows: [
                    Shadow(
                      color: AppColors.black.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                children: [
                  // White spans inherit color from parent TextSpan
                  const TextSpan(text: "Hàng ngàn "),
                  TextSpan(
                    text: "món ngon ",
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 30,
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(text: "chỉ một chạm với "),
                  TextSpan(
                    text: "FoodHit.",
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 30,
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.transparent,
            AppColors.black.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),

          // ── Đăng nhập bằng Email ─────────────────────
          GradientActionButton(
            icon: Icons.email_outlined,
            iconColor: AppColors.primaryOrange,
            text: "Đăng nhập bằng Email",
            isPrimary: true,
            onTap: () => Get.toNamed(AppRoutes.emailLogin),
          ),

          const SizedBox(height: 12),

          // ── Đăng nhập bằng Google ────────────────────
          GoogleSignInButton(
            onTap: () {
              // TODO: Implement Google Sign In
            },
          ),

          const SizedBox(height: 16),

          // ── Divider "hoặc" ──────────────────────────
          _buildDivider(),

          const SizedBox(height: 16),

          // ── Đăng ký tài khoản mới ────────────────────
          GradientActionButton(
            icon: Icons.person_add_outlined,
            iconColor: AppColors.white,
            text: "Đăng ký tài khoản mới",
            isPrimary: false,
            onTap: () => Get.toNamed(AppRoutes.register),
          ),

          const SizedBox(height: 40),
        ],
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
                  AppColors.white.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "hoặc",
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.white,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.white.withValues(alpha: 0.6),
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
