import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../controllers/email_login_controller.dart';
import '../widgets/shake_widget.dart';

class EmailLoginView extends StatefulWidget {
  const EmailLoginView({super.key});

  @override
  State<EmailLoginView> createState() => _EmailLoginViewState();
}

class _EmailLoginViewState extends State<EmailLoginView> {
  late final EmailLoginController controller;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool? _emailValid; // null=empty, true=valid, false=invalid
  bool? _passValid;
  final Set<String> _shaking = {};
  final List<Worker> _workers = [];

  @override
  void initState() {
    super.initState();
    controller = Get.find<EmailLoginController>();
    controller.onSavedCredentialsLoaded = (email, password) {
      _emailCtrl.text = email;
      _passCtrl.text = password;
      setState(() {
        _emailValid = email.isNotEmpty ? GetUtils.isEmail(email) : null;
        _passValid = password.isNotEmpty ? true : null;
      });
    };

    _emailFocus.addListener(() => setState(() {}));
    _passFocus.addListener(() => setState(() {}));

    _emailCtrl.addListener(() {
      if (!mounted) return;
      final v = _emailCtrl.text;
      setState(
          () => _emailValid = v.isEmpty ? null : GetUtils.isEmail(v.trim()));
    });

    _passCtrl.addListener(() {
      if (!mounted) return;
      final v = _passCtrl.text;
      setState(() => _passValid = v.isEmpty ? null : v.isNotEmpty);
    });

    _workers.addAll([
      ever(controller.emailError, (e) {
        if (e.isNotEmpty) _shake('email');
      }),
      ever(controller.passwordError, (e) {
        if (e.isNotEmpty) _shake('password');
      }),
    ]);
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
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
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
                        const SizedBox(height: 36),
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
                top: -20, right: -20, child: _wm(Icons.eco_rounded, 180)),
            Positioned(
                top: 140,
                left: -30,
                child: _wm(Icons.restaurant_menu_rounded, 120)),
            Positioned(
                bottom: 100,
                right: -10,
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
            Text('Đăng nhập ',
                style: AppTextStyles.h1.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [AppColors.emeraldDark, AppColors.emeraldLight],
              ).createShader(b),
              child: Text('Admin',
                  style: AppTextStyles.h1.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('Hệ thống quản trị nội bộ FoodHit',
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey)),
      ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email
          Obx(() => _buildField(
                fieldKey: 'email',
                ctrl: _emailCtrl,
                focus: _emailFocus,
                hint: 'Email quản trị',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                localValid: _emailValid,
                errorText: controller.emailError.value,
                action: TextInputAction.next,
                onSubmitted: () => _passFocus.requestFocus(),
              )),
          const SizedBox(height: 16),

          // Password
          Obx(() => _buildField(
                fieldKey: 'password',
                ctrl: _passCtrl,
                focus: _passFocus,
                hint: 'Mật khẩu',
                icon: Icons.lock_outline_rounded,
                obscureText: !controller.isPasswordVisible.value,
                localValid: _passValid,
                errorText: controller.passwordError.value,
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
          const SizedBox(height: 12),

          // Remember me + Forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => _buildRememberMe()),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4)),
                child: Text(
                  'Quên mật khẩu?',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.emerald, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Obx(() => _buildLoginButton()),
        ],
      ),
    );
  }

  Widget _buildField({
    required String fieldKey,
    required TextEditingController ctrl,
    required FocusNode focus,
    required String hint,
    required IconData icon,
    bool? localValid,
    String errorText = '',
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    VoidCallback? onSubmitted,
    Widget? suffix,
  }) {
    final isFocused = focus.hasFocus;
    final isShaking = _shaking.contains(fieldKey);

    final Color borderColor;
    final Color bgColor;

    if (errorText.isNotEmpty || localValid == false) {
      borderColor = AppColors.errorRed;
      bgColor = AppColors.errorRed.withValues(alpha: 0.04);
    } else if (localValid == true) {
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
                width: (isFocused || localValid != null) ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: ctrl,
              focusNode: focus,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: action,
              onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textLight),
                prefixIcon: Icon(icon,
                    color: localValid == true
                        ? AppColors.emerald
                        : isFocused
                            ? AppColors.emerald
                            : AppColors.grey400,
                    size: 20),
                suffixIcon: suffix ??
                    (localValid == true
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.emerald, size: 20)
                        : null),
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

  Widget _buildRememberMe() {
    return InkWell(
      onTap: controller.toggleRememberMe,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: controller.rememberMe.value
                    ? AppColors.emerald
                    : AppColors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: controller.rememberMe.value
                      ? AppColors.emerald
                      : AppColors.grey400,
                  width: 1.5,
                ),
              ),
              child: controller.rememberMe.value
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Text('Nhớ tôi',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textGrey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final isLoading = controller.isLoading.value;
    return GestureDetector(
      onTap: isLoading
          ? null
          : () => controller.login(
                email: _emailCtrl.text,
                password: _passCtrl.text,
              ),
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
            const Icon(Icons.login_rounded, color: AppColors.white, size: 20),
            const SizedBox(width: 10),
            Text('Đăng nhập',
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
