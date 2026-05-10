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
  final _passFocus = FocusNode();
  final _confirmPassFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = Get.find<ResetPasswordController>();
    _passFocus.addListener(() => setState(() {}));
    _confirmPassFocus.addListener(() => setState(() {}));
    _passCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _passFocus.dispose();
    _confirmPassFocus.dispose();
    super.dispose();
  }

  int _passwordStrength(String pw) {
    int s = 0;
    if (pw.length >= 8) s++;
    if (pw.contains(RegExp(r'[A-Z]'))) s++;
    if (pw.contains(RegExp(r'[a-z]'))) s++;
    if (pw.contains(RegExp(r'[0-9]'))) s++;
    if (pw.contains(RegExp(r'[@$!%*?&]'))) s++;
    return s;
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
            border:
                Border.all(color: AppColors.emerald.withValues(alpha: 0.25)),
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
              'Đặt lại ',
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
                'mật khẩu',
                style: AppTextStyles.h1.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Nhập mật khẩu mới cho tài khoản Admin của bạn.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
        ),
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
          Icons.lock_reset_rounded,
          size: 42,
          color: AppColors.emerald,
        ),
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
          // New password
          Obx(() => _buildField(
                controller: _passCtrl,
                focusNode: _passFocus,
                hint: 'Mật khẩu mới',
                icon: Icons.lock_outline_rounded,
                obscureText: !controller.isPasswordVisible.value,
                errorText: controller.passwordError.value,
                action: TextInputAction.next,
                onSubmitted: () => _confirmPassFocus.requestFocus(),
                suffix: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: AppColors.emerald.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              )),

          // Password strength
          if (_passCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildPasswordStrength(_passCtrl.text),
          ],

          const SizedBox(height: 16),

          // Confirm password
          Obx(() => _buildField(
                controller: _confirmPassCtrl,
                focusNode: _confirmPassFocus,
                hint: 'Xác nhận mật khẩu mới',
                icon: Icons.lock_outline_rounded,
                obscureText: !controller.isConfirmPasswordVisible.value,
                errorText: controller.confirmPasswordError.value,
                action: TextInputAction.done,
                onSubmitted: () => _submit(),
                suffix: IconButton(
                  icon: Icon(
                    controller.isConfirmPasswordVisible.value
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: AppColors.emerald.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
              )),

          const SizedBox(height: 28),
          Obx(() => _buildResetButton()),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    String errorText = '',
    bool obscureText = false,
    TextInputAction action = TextInputAction.next,
    VoidCallback? onSubmitted,
    Widget? suffix,
  }) {
    final isFocused = focusNode.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isFocused
                ? AppColors.emerald.withValues(alpha: 0.04)
                : AppColors.grey100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFocused
                  ? AppColors.emerald
                  : errorText.isNotEmpty
                      ? AppColors.errorRed
                      : AppColors.grey300,
              width: isFocused ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            textInputAction: action,
            onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
              prefixIcon: Icon(
                icon,
                color: isFocused ? AppColors.emerald : AppColors.grey400,
                size: 20,
              ),
              suffixIcon: suffix,
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
                color: AppColors.errorRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordStrength(String password) {
    final strength = _passwordStrength(password);
    final Color color;
    final String label;
    final double fraction;

    if (strength <= 2) {
      color = AppColors.errorRed;
      label = 'Yếu';
      fraction = 0.33;
    } else if (strength <= 3) {
      color = AppColors.warningYellow;
      label = 'Vừa';
      fraction = 0.66;
    } else {
      color = AppColors.emerald;
      label = 'Mạnh';
      fraction = 1.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Độ mạnh mật khẩu',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 5,
            backgroundColor: AppColors.grey200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    final isLoading = controller.isLoading.value;
    return GestureDetector(
      onTap: isLoading ? null : _submit,
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
            const Icon(Icons.lock_reset_rounded,
                color: AppColors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Đổi mật khẩu',
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

  void _submit() {
    controller.resetPassword(
      newPassword: _passCtrl.text,
      confirmPassword: _confirmPassCtrl.text,
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
