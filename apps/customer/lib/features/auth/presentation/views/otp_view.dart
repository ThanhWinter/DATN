import "package:core_ui/core_ui.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:get/get.dart";

import "../controllers/otp_controller.dart";

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  late final OtpController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OtpController>();

    for (int i = 0; i < 6; i++) {
      final index = i;

      // Backspace trên ô trống → xóa ô trước và lùi focus
      _focusNodes[index].onKeyEvent = (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[index].text.isEmpty &&
            index > 0) {
          _controllers[index - 1].clear();
          _focusNodes[index - 1].requestFocus();
          _onOtpChanged();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };

      // Select-all khi focus vào ô đã có số → gõ đè ngay
      _focusNodes[index].addListener(() {
        if (_focusNodes[index].hasFocus && _controllers[index].text.isNotEmpty) {
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged() {
    final otp = _controllers.map((c) => c.text).join();
    controller.onOtpChanged(otp);
    if (otp.length == 6) {
      FocusScope.of(context).unfocus();
      controller.verify();
    }
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
                        const SizedBox(height: 32),
                        
                        Text(
                          "Xác thực OTP",
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Obx(() => RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                            children: [
                              const TextSpan(text: "Mã xác thực đã được gửi đến email "),
                              TextSpan(
                                text: controller.email.value,
                                style: const TextStyle(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )),
                        
                        const SizedBox(height: 48),
                        
                        // ── OTP Input Fields ────────────────────────────────
                        _buildOtpInput(),
                        
                        const SizedBox(height: 48),
                        
                        // ── Nút Xác thực ─────────────────────────────────────
                        Obx(() => GradientActionButton(
                          icon: Icons.verified_user_outlined,
                          iconColor: AppColors.primaryOrange,
                          text: "Xác thực ngay",
                          isPrimary: true,
                          onTap: controller.isLoading.value ? () {} : controller.verify,
                        )),
                        
                        const SizedBox(height: 32),
                        
                        // ── Gửi lại mã OTP ────────────────────────────────────
                        Obx(() {
                          final countdown = controller.resendCountdown.value;
                          final isResending = controller.isResending.value;

                          return Center(
                            child: TextButton(
                              onPressed: (countdown > 0 || isResending)
                                  ? null
                                  : controller.resendOtp,
                              child: isResending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: AppColors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      countdown > 0
                                          ? "Gửi lại sau ${countdown}s"
                                          : "Chưa nhận được mã? Gửi lại",
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: countdown > 0
                                            ? AppColors.white.withValues(alpha: 0.5)
                                            : AppColors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        }),
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
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
        onPressed: Get.back,
      ),
    );
  }

  Widget _buildOtpInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => Container(
          width: 45,
          height: 55,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
              _onOtpChanged();
            },
            style: AppTextStyles.h2.copyWith(color: AppColors.white),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: "",
            ),
          ),
        ),
      ),
    );
  }
}
