import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final ForgotPasswordController controller;
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<ForgotPasswordController>();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Quên mật khẩu',
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
                        Text(
                          'Nhập email quản trị để nhận mã xác thực khôi phục mật khẩu.',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Obx(() => _buildInputSection(
                              child: GlassInputField(
                                controller: _emailCtrl,
                                hintText: 'Nhập email của bạn',
                                svgPath: AppIcons.emailSvg,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              errorText: controller.emailError.value,
                            )),
                        const SizedBox(height: 40),
                        Obx(() => GradientActionButton(
                              icon: AppIcons.send,
                              iconColor: AppColors.primaryOrange,
                              text: 'Gửi mã xác thực',
                              isPrimary: true,
                              onTap: controller.isLoading.value
                                  ? () {}
                                  : () => controller.sendOtp(_emailCtrl.text),
                            )),
                        const SizedBox(height: 24),
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
