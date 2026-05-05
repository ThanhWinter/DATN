import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../controllers/otp_controller.dart';
import '../widgets/register_success_dialog.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  late final OtpController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OtpController>();
    controller.onRegisterSuccess = _showSuccessDialog;

    for (int i = 0; i < 6; i++) {
      final index = i;

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

      _focusNodes[index].addListener(() {
        if (_focusNodes[index].hasFocus &&
            _controllers[index].text.isNotEmpty) {
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          );
        }
        setState(() {});
      });

      _controllers[index].addListener(() => setState(() {}));
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.black.withValues(alpha: 0.4),
      builder: (_) => RegisterSuccessDialog(
        onContinue: () async {
          Get.back();
          await Future.delayed(const Duration(milliseconds: 500));
          Get.offAllNamed(AppRoutes.login);
        },
      ),
    );
  }

  void _onOtpChanged() {
    final otp = _controllers.map((c) => c.text).join();
    controller.otpTextCtrl.text = otp;
    if (otp.length == 6) {
      FocusScope.of(context).unfocus();
      controller.verify();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mintBg,
      body: Stack(
        children: [
          _buildWatermarks(),
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
                        const SizedBox(height: 12),
                        _buildTitle(),
                        const SizedBox(height: 28),
                        _buildHeroIcon(),
                        const SizedBox(height: 28),
                        _buildOtpCard(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() => _buildLoadingOverlay(controller.isLoading.value)),
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
              child: _watermark(Icons.eco_rounded, 180),
            ),
            Positioned(
              top: 160,
              left: -30,
              child: _watermark(Icons.restaurant_menu_rounded, 120),
            ),
            Positioned(
              bottom: 80,
              right: -10,
              child: _watermark(Icons.local_dining_rounded, 140),
            ),
          ],
        ),
      ),
    );
  }

  Widget _watermark(IconData icon, double size) =>
      Icon(icon, size: size, color: AppColors.emerald.withValues(alpha: 0.05));

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 8),
      child: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.emerald.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: AppColors.emerald.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.emerald,
            size: 18,
          ),
        ),
        onPressed: Get.back,
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Xác thực ',
              style: AppTextStyles.h1.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [AppColors.emeraldDark, AppColors.emeraldLight],
              ).createShader(b),
              child: Text(
                'OTP',
                style: AppTextStyles.h1.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textGrey,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Mã 6 số đã được gửi tới email\n'),
                  TextSpan(
                    text: controller.email.value,
                    style: const TextStyle(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildHeroIcon() {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.emerald.withValues(alpha: 0.35),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.emerald.withValues(alpha: 0.18),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Icon(
          Icons.verified_rounded,
          size: 42,
          color: AppColors.emerald,
        ),
      ),
    );
  }

  Widget _buildOtpCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.emerald.withValues(alpha: 0.18),
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
        children: [
          _buildOtpBoxes(),
          const SizedBox(height: 28),
          Obx(() => _buildVerifyButton()),
          const SizedBox(height: 20),
          Obx(() => _buildResendRow()),
        ],
      ),
    );
  }

  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        final isFocused = _focusNodes[index].hasFocus;
        final isFilled = _controllers[index].text.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 52,
          decoration: BoxDecoration(
            color: isFocused
                ? AppColors.emerald.withValues(alpha: 0.04)
                : AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFocused
                  ? AppColors.emerald
                  : isFilled
                      ? AppColors.emerald.withValues(alpha: 0.5)
                      : AppColors.grey300,
              width: isFocused ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            expands: true,
            maxLines: null,
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
              _onOtpChanged();
            },
            style: AppTextStyles.h2.copyWith(
              color: isFilled ? AppColors.emerald : AppColors.textDark,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            cursorColor: AppColors.emerald,
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    final isLoading = controller.isLoading.value;
    return GestureDetector(
      onTap: isLoading ? null : controller.verify,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: isLoading
              ? null
              : const LinearGradient(
                  colors: [
                    AppColors.emeraldDark,
                    AppColors.emerald,
                    AppColors.emeraldLight,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: isLoading ? AppColors.grey300 : null,
          borderRadius: BorderRadius.circular(28),
          boxShadow: isLoading
              ? null
              : [
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
            const Icon(Icons.verified_user_rounded,
                color: AppColors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Xác thực ngay',
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

  Widget _buildResendRow() {
    final secs = controller.countdown.value;
    final canResend = secs <= 0 && !controller.isResending.value;

    return Center(
      child: controller.isResending.value
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.emerald,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chưa nhận được mã? ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
                GestureDetector(
                  onTap: canResend ? controller.resendOtp : null,
                  child: Text(
                    secs > 0 ? 'Gửi lại (${secs}s)' : 'Gửi lại',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: canResend
                          ? AppColors.emerald
                          : AppColors.textLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLoadingOverlay(bool isLoading) {
    if (!isLoading) return const SizedBox.shrink();
    return Container(
      color: AppColors.black.withValues(alpha: 0.25),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.emerald.withValues(alpha: 0.15),
                blurRadius: 24,
              ),
            ],
          ),
          child: const CircularProgressIndicator(
            color: AppColors.emerald,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}
