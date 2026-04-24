import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  late final ResetPasswordController controller;
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<ResetPasswordController>();
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Đặt lại mật khẩu',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 28,
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nhập mật khẩu mới cho tài khoản admin của bạn.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      Obx(() => _buildInputSection(
                            child: GlassInputField(
                              controller: _passCtrl,
                              hintText: 'Mật khẩu mới',
                              svgPath: AppIcons.lockSvg,
                              obscureText: !controller.isPasswordVisible.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordVisible.value
                                      ? AppIcons.visibilityOn
                                      : AppIcons.visibilityOff,
                                  color: AppColors.white.withValues(alpha: 0.7),
                                  size: 22,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                            errorText: controller.passwordError.value,
                          )),
                      
                      const SizedBox(height: 16),
                      
                      Obx(() => _buildInputSection(
                            child: GlassInputField(
                              controller: _confirmPassCtrl,
                              hintText: 'Xác nhận mật khẩu mới',
                              svgPath: AppIcons.lockSvg,
                              obscureText: !controller.isConfirmPasswordVisible.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isConfirmPasswordVisible.value
                                      ? AppIcons.visibilityOn
                                      : AppIcons.visibilityOff,
                                  color: AppColors.white.withValues(alpha: 0.7),
                                  size: 22,
                                ),
                                onPressed: controller.toggleConfirmPasswordVisibility,
                              ),
                            ),
                            errorText: controller.confirmPasswordError.value,
                          )),
                      
                      const SizedBox(height: 32),
                      
                      Obx(() => GradientActionButton(
                            svgPath: AppIcons.lockSvg,
                            iconColor: AppColors.primaryOrange,
                            text: 'Đổi mật khẩu',
                            isPrimary: true,
                            onTap: controller.isLoading.value
                                ? () {}
                                : () => controller.resetPassword(
                                      newPassword: _passCtrl.text,
                                      confirmPassword: _confirmPassCtrl.text,
                                    ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Obx(() => controller.isLoading.value
              ? Container(
                  color: AppColors.black.withValues(alpha: 0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.white),
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
        icon: const Icon(AppIcons.backArrowSimple, color: AppColors.white),
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
