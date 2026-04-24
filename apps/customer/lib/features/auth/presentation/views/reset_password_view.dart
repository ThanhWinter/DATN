import "package:core_ui/core_ui.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

import "../controllers/reset_password_controller.dart";

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  late final ResetPasswordController controller;

  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<ResetPasswordController>();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
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
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        Text(
                          "Mật khẩu mới",
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Obx(() => RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.white.withValues(alpha: 0.8)),
                                children: [
                                  const TextSpan(text: "Đặt mật khẩu mới cho "),
                                  TextSpan(
                                    text: controller.email.value,
                                    style: const TextStyle(
                                        color: AppColors.accentGold,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )),

                        const SizedBox(height: 40),

                        // ── Mật khẩu mới ───────────────────────────────────────
                        Obx(() => _buildInputSection(
                              child: GlassInputField(
                                controller: _passwordCtrl,
                                hintText: "Mật khẩu mới",
                                icon: Icons.lock_outline,
                                obscureText: !controller.isPasswordVisible.value,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppColors.white.withValues(alpha: 0.7),
                                    size: 22,
                                  ),
                                  onPressed: controller.togglePassword,
                                ),
                              ),
                              errorText: controller.passwordError.value,
                            )),

                        const SizedBox(height: 16),

                        // ── Xác nhận mật khẩu ──────────────────────────────────
                        Obx(() => _buildInputSection(
                              child: GlassInputField(
                                controller: _confirmPasswordCtrl,
                                hintText: "Nhập lại mật khẩu mới",
                                icon: Icons.lock_outline,
                                obscureText:
                                    !controller.isConfirmPasswordVisible.value,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isConfirmPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppColors.white.withValues(alpha: 0.7),
                                    size: 22,
                                  ),
                                  onPressed: controller.toggleConfirmPassword,
                                ),
                              ),
                              errorText: controller.confirmPasswordError.value,
                            )),

                        const SizedBox(height: 40),

                        // ── Nút xác nhận ───────────────────────────────────────
                        Obx(() => GradientActionButton(
                              icon: Icons.check_circle_outline,
                              iconColor: AppColors.primaryOrange,
                              text: "Xác nhận đặt lại",
                              isPrimary: true,
                              onTap: controller.isLoading.value
                                  ? () {}
                                  : () => controller.resetPassword(
                                        newPassword: _passwordCtrl.text,
                                        confirmPassword:
                                            _confirmPasswordCtrl.text,
                                      ),
                            )),

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
                        color: AppColors.white, strokeWidth: 3),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
        onPressed: Get.back,
      ),
    );
  }

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
            child: Text(errorText,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.accentGold, fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }
}
