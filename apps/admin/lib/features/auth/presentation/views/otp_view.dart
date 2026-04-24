import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background Gradient ──────────────────────────────────────────
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

          // ── Main Content ─────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        
                        // Icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.mark_email_read_outlined,
                            size: 52,
                            color: AppColors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        Text(
                          'Xác thực OTP',
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 32,
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Obx(() => RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.8),
                                ),
                                children: [
                                  const TextSpan(text: 'Mã xác thực đã được gửi đến\n'),
                                  TextSpan(
                                    text: controller.email.value,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.accentGold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )),

                        const SizedBox(height: 48),

                        // OTP Input
                        GlassInputField(
                          controller: controller.otpTextCtrl,
                          hintText: 'Nhập mã 6 chữ số',
                          icon: Icons.pin_outlined,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          onSubmitted: () => controller.verify(),
                        ),

                        const SizedBox(height: 32),

                        // Nút xác nhận
                        Obx(() => GradientActionButton(
                              icon: AppIcons.send,
                              iconColor: AppColors.primaryOrange,
                              text: 'Xác thực',
                              isPrimary: true,
                              onTap: controller.isLoading.value
                                  ? () {}
                                  : () => controller.verify(),
                            )),

                        const SizedBox(height: 24),

                        // Gửi lại OTP
                        Obx(() {
                          final secs = controller.countdown.value;
                          final canResend = secs <= 0 && !controller.isResending.value;
                          return Opacity(
                            opacity: canResend ? 1.0 : 0.7,
                            child: InkWell(
                              onTap: canResend ? controller.resendOtp : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.refresh_rounded,
                                      size: 20,
                                      color: canResend
                                          ? AppColors.white
                                          : AppColors.white.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      canResend
                                          ? 'Gửi lại mã OTP'
                                          : 'Gửi lại sau ${secs}s',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: canResend
                                            ? AppColors.white
                                            : AppColors.white.withValues(alpha: 0.5),
                                        fontWeight: canResend
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
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
}
