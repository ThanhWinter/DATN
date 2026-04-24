import "package:core_ui/core_ui.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

import "../../../../app/routes/app_routes.dart";
import "../controllers/email_login_controller.dart";

/// Màn hình đăng nhập bằng Email — mirror UI của email_login_screen
/// trong fo_mobile, được điều chỉnh theo design system orange/gold của food_hit.
///
/// Dùng StatefulWidget để quản lý lifecycle của TextEditingController (Rule 10).
class EmailLoginView extends StatefulWidget {
  const EmailLoginView({super.key});

  @override
  State<EmailLoginView> createState() => _EmailLoginViewState();
}

class _EmailLoginViewState extends State<EmailLoginView> {
  late final EmailLoginController controller;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<EmailLoginController>();

    // Pre-fill nếu có thông tin đã lưu
    controller.onSavedCredentialsLoaded = (email, password) {
      _emailCtrl.text = email;
      _passCtrl.text = password;
    };
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background Gradient ────────────────────────────────────────────
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

          // ── Nội dung chính ─────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom AppBar với nút back
                _buildAppBar(),

                // Form cuộn được
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // ── Tiêu đề ─────────────────────────────────────────
                        Text(
                          "Chào mừng trở lại!",
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
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

                        const SizedBox(height: 8),

                        // ── Phụ đề ──────────────────────────────────────────
                        Text(
                          "Vui lòng đăng nhập để tiếp tục",
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── Ô nhập Email ─────────────────────────────────────
                        Obx(() => _buildInputSection(
                              child: GlassInputField(
                                controller: _emailCtrl,
                                hintText: "Nhập email của bạn",
                                svgPath: AppIcons.emailSvg,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              errorText: controller.emailError.value,
                            )),

                        const SizedBox(height: 16),

                        // ── Ô nhập Mật khẩu ──────────────────────────────────
                        Obx(() => _buildInputSection(
                              child: GlassInputField(
                                controller: _passCtrl,
                                hintText: "Nhập mật khẩu",
                                svgPath: AppIcons.lockSvg,
                                obscureText:
                                    !controller.isPasswordVisible.value,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordVisible.value
                                        ? AppIcons.visibilityOn
                                        : AppIcons.visibilityOff,
                                    color:
                                        AppColors.white.withValues(alpha: 0.7),
                                    size: 22,
                                  ),
                                  onPressed: controller.togglePasswordVisibility,
                                ),
                              ),
                              errorText: controller.passwordError.value,
                            )),

                        const SizedBox(height: 8),

                        // ── Nhớ tôi + Quên mật khẩu ─────────────────────────
                        Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Checkbox "Nhớ tôi" — căn trái thẳng icon email/lock
                              Obx(() => InkWell(
                                    onTap: controller.toggleRememberMe,
                                    borderRadius: BorderRadius.circular(8),
                                    splashColor:
                                        AppColors.accentGold.withValues(alpha: 0.2),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedContainer(
                                            duration:
                                                const Duration(milliseconds: 200),
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: controller.rememberMe.value
                                                  ? AppColors.accentGold
                                                  : AppColors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                color: controller.rememberMe.value
                                                    ? AppColors.accentGold
                                                    : AppColors.white
                                                        .withValues(alpha: 0.6),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: controller.rememberMe.value
                                                ? const Icon(
                                                    Icons.check_rounded,
                                                    size: 14,
                                                    color: AppColors
                                                        .primaryOrangeDark,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Nhớ tôi",
                                            style:
                                                AppTextStyles.bodyMedium.copyWith(
                                              color: AppColors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),

                              // Quên mật khẩu
                              TextButton(
                                onPressed: () =>
                                    Get.toNamed(AppRoutes.forgotPassword),
                                child: Text(
                                  "Quên mật khẩu?",
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.accentGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Nút Đăng nhập ─────────────────────────────────────
                        Obx(
                          () => GradientActionButton(
                            icon: AppIcons.login,
                            iconColor: AppColors.primaryOrange,
                            text: "Đăng nhập",
                            isPrimary: true,
                            onTap: controller.isLoading.value
                                ? () {}
                                : () => controller.login(
                                      email: _emailCtrl.text,
                                      password: _passCtrl.text,
                                    ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Loading Overlay ────────────────────────────────────────────────
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

  // ── Widgets cục bộ ──────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: IconButton(
        icon: const Icon(AppIcons.backArrowSimple, color: AppColors.white),
        onPressed: Get.back,
      ),
    );
  }

  /// Bọc input field kèm error text bên dưới (nếu có).
  Widget _buildInputSection({
    required Widget child,
    required String errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        if (errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 16),
            child: Text(
              errorText,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.accentGold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
