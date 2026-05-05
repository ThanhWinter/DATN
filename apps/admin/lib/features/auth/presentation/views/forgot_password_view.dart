import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';
import '../widgets/shake_widget.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final ForgotPasswordController controller;
  final _emailCtrl = TextEditingController();
  final _emailFocus = FocusNode();

  bool? _emailValid;
  final Set<String> _shaking = {};
  final List<Worker> _workers = [];

  @override
  void initState() {
    super.initState();
    controller = Get.find<ForgotPasswordController>();

    _emailFocus.addListener(() => setState(() {}));

    _emailCtrl.addListener(() {
      if (!mounted) return;
      final v = _emailCtrl.text;
      setState(() => _emailValid = v.isEmpty ? null : GetUtils.isEmail(v.trim()));
    });

    _workers.add(
      ever(controller.emailError, (e) { if (e.isNotEmpty) _shake('email'); }),
    );
  }

  void _shake(String key) {
    if (!mounted) return;
    setState(() => _shaking.add(key));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _shaking.remove(key));
    });
  }

  @override
  void dispose() {
    for (final w in _workers) {
      w.dispose();
    }
    _emailCtrl.dispose();
    _emailFocus.dispose();
    super.dispose();
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
                        const SizedBox(height: 32),
                        _buildHeroIcon(),
                        const SizedBox(height: 32),
                        _buildFormCard(),
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
            Positioned(top: -20, right: -20,
                child: _wm(Icons.eco_rounded, 180)),
            Positioned(top: 160, left: -30,
                child: _wm(Icons.restaurant_menu_rounded, 120)),
            Positioned(bottom: 80, right: -10,
                child: _wm(Icons.local_dining_rounded, 140)),
          ],
        ),
      ),
    );
  }

  Widget _wm(IconData icon, double size) =>
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
            border:
                Border.all(color: AppColors.emerald.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  blurRadius: 8),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.emerald, size: 18),
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
            Text('Quên ',
                style: AppTextStyles.h1.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [AppColors.emeraldDark, AppColors.emeraldLight],
              ).createShader(b),
              child: Text('mật khẩu?',
                  style: AppTextStyles.h1.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Nhập email liên kết với tài khoản Admin.\nChúng tôi sẽ gửi mã OTP để đặt lại mật khẩu.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textGrey, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildHeroIcon() {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(
              color: AppColors.emerald.withValues(alpha: 0.35), width: 2),
          boxShadow: [
            BoxShadow(
                color: AppColors.emerald.withValues(alpha: 0.18),
                blurRadius: 24,
                spreadRadius: 4),
          ],
        ),
        child:
            const Icon(Icons.mark_email_unread_rounded, size: 46, color: AppColors.emerald),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: AppColors.emerald.withValues(alpha: 0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppColors.emerald.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8)),
          BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Obx(() => _buildEmailField(controller.emailError.value)),
          const SizedBox(height: 24),
          Obx(() => _buildSendButton()),
        ],
      ),
    );
  }

  Widget _buildEmailField(String errorText) {
    final isFocused = _emailFocus.hasFocus;
    final isShaking = _shaking.contains('email');

    final Color borderColor;
    final Color bgColor;

    if (errorText.isNotEmpty || _emailValid == false) {
      borderColor = AppColors.errorRed;
      bgColor = AppColors.errorRed.withValues(alpha: 0.04);
    } else if (_emailValid == true) {
      borderColor = AppColors.emerald;
      bgColor = AppColors.emerald.withValues(alpha: 0.04);
    } else if (isFocused) {
      borderColor = AppColors.emerald;
      bgColor = AppColors.emerald.withValues(alpha: 0.04);
    } else {
      borderColor = AppColors.grey300;
      bgColor = AppColors.grey100;
    }

    return ShakeWidget(
      shouldShake: isShaking,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: (isFocused || _emailValid != null) ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: _emailCtrl,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.sendOtp(_emailCtrl.text),
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Email quản trị',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textLight),
                prefixIcon: Icon(
                  Icons.alternate_email_rounded,
                  color: _emailValid == true
                      ? AppColors.emerald
                      : isFocused
                          ? AppColors.emerald
                          : AppColors.grey400,
                  size: 20,
                ),
                suffixIcon: _emailValid == true
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.emerald, size: 20)
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              ),
              cursorColor: AppColors.emerald,
            ),
          ),
          if (errorText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 14),
              child: Text(
                errorText,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.errorRed, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    final isLoading = controller.isLoading.value;
    return GestureDetector(
      onTap: isLoading ? null : () => controller.sendOtp(_emailCtrl.text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
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
            const Icon(Icons.send_rounded, color: AppColors.white, size: 20),
            const SizedBox(width: 10),
            Text('Gửi mã OTP',
                style: AppTextStyles.button.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3)),
          ],
        ),
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
                  blurRadius: 24),
            ],
          ),
          child: const CircularProgressIndicator(
              color: AppColors.emerald, strokeWidth: 3),
        ),
      ),
    );
  }
}
