import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../controllers/register_controller.dart';
import '../widgets/shake_widget.dart';

enum _BtnState { idle, loading, success }

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final RegisterController controller;

  final _lastNameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _lastNameFocus = FocusNode();
  final _firstNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _dobFocus = FocusNode();

  bool _agreedToTerms = false;
  _BtnState _btnState = _BtnState.idle;

  // null = empty/untouched, true = valid, false = invalid
  final Map<String, bool?> _fieldValid = {};
  // which fields are currently shaking
  final Set<String> _shaking = {};

  final List<Worker> _workers = [];

  @override
  void initState() {
    super.initState();
    controller = Get.find<RegisterController>();

    for (final f in [
      _lastNameFocus,
      _firstNameFocus,
      _emailFocus,
      _phoneFocus,
      _dobFocus,
      _passwordFocus,
      _confirmPasswordFocus,
    ]) {
      f.addListener(() => setState(() {}));
    }

    _addListener(_lastNameCtrl, 'lastName');
    _addListener(_firstNameCtrl, 'firstName');
    _addListener(_emailCtrl, 'email');
    _addListener(_phoneCtrl, 'phone');
    _addListener(_passwordCtrl, 'password');
    _addListener(_confirmPasswordCtrl, 'confirmPassword');

    _workers.addAll([
      ever(controller.lastNameError, (e) {
        if (e.isNotEmpty) _shake('lastName');
      }),
      ever(controller.firstNameError, (e) {
        if (e.isNotEmpty) _shake('firstName');
      }),
      ever(controller.emailError, (e) {
        if (e.isNotEmpty) _shake('email');
      }),
      ever(controller.phoneError, (e) {
        if (e.isNotEmpty) _shake('phone');
      }),
      ever(controller.dobError, (e) {
        if (e.isNotEmpty) _shake('dob');
      }),
      ever(controller.passwordError, (e) {
        if (e.isNotEmpty) _shake('password');
      }),
      ever(controller.confirmPasswordError, (e) {
        if (e.isNotEmpty) _shake('confirmPassword');
      }),

      // Button morphing: success → show checkmark → navigate to OTP
      ever(controller.registerSuccess, (bool ok) {
        if (!ok || !mounted) return;
        setState(() => _btnState = _BtnState.success);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          Get.toNamed(AppRoutes.otp, arguments: {
            'email': controller.pendingEmail,
            'type': 'REGISTER',
          });
        });
      }),

      // Reset button if API returns error
      ever(controller.isLoading, (bool loading) {
        if (!loading && mounted && _btnState == _BtnState.loading) {
          setState(() => _btnState = _BtnState.idle);
        }
      }),
    ]);
  }

  void _addListener(TextEditingController ctrl, String key) {
    ctrl.addListener(() {
      if (!mounted) return;
      setState(() {
        _fieldValid[key] = _validateLocally(key, ctrl.text);
        if (key == 'password' && _confirmPasswordCtrl.text.isNotEmpty) {
          _fieldValid['confirmPassword'] =
              _validateLocally('confirmPassword', _confirmPasswordCtrl.text);
        }
      });
    });
  }

  bool? _validateLocally(String key, String value) {
    if (value.isEmpty) return null;
    return switch (key) {
      'email' => GetUtils.isEmail(value.trim()),
      'phone' => RegExp(r'^\d{10}$').hasMatch(value.trim()),
      'lastName' || 'firstName' => value.trim().isNotEmpty,
      'password' => _passwordStrength(value) >= 4,
      'confirmPassword' => value == _passwordCtrl.text,
      _ => null,
    };
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
    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _lastNameFocus.dispose();
    _firstNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: AppColors.emerald,
            onPrimary: AppColors.white,
            onSurface: AppColors.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      if (!mounted) return;
      controller.setDob(picked);
      final d = picked.day.toString().padLeft(2, '0');
      final m = picked.month.toString().padLeft(2, '0');
      _dobCtrl.text = '$d/$m/${picked.year}';
      setState(() => _fieldValid['dob'] = true);
    }
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

  void _submitRegister() {
    if (!_agreedToTerms || _btnState != _BtnState.idle) return;
    setState(() => _btnState = _BtnState.loading);
    controller.register(
      firstName: _firstNameCtrl.text,
      lastName: _lastNameCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      password: _passwordCtrl.text,
      confirmPassword: _confirmPasswordCtrl.text,
    );
    // If validation failed synchronously, isLoading stays false → reset
    if (!controller.isLoading.value && !controller.registerSuccess.value) {
      setState(() => _btnState = _BtnState.idle);
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
                        const SizedBox(height: 24),
                        _buildFormCard(),
                        const SizedBox(height: 20),
                        _buildFooter(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Layout helpers ───────────────────────────────────────────────────────────

  Widget _buildWatermarks() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
                top: -20, right: -20, child: _wm(Icons.eco_rounded, 180)),
            Positioned(
                top: 200,
                left: -30,
                child: _wm(Icons.restaurant_menu_rounded, 120)),
            Positioned(
                bottom: 60,
                right: -10,
                child: _wm(Icons.local_dining_rounded, 140)),
            Positioned(
                bottom: 280, left: -20, child: _wm(Icons.grass_rounded, 100)),
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
            Text('Tạo tài khoản ',
                style: AppTextStyles.h1.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [AppColors.emeraldDark, AppColors.emeraldLight],
              ).createShader(b),
              child: Text('Admin',
                  style: AppTextStyles.h1.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Vui lòng điền đầy đủ thông tin bên dưới',
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
          // Họ / Tên
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildField(
                      fieldKey: 'lastName',
                      ctrl: _lastNameCtrl,
                      focus: _lastNameFocus,
                      hint: 'Họ',
                      icon: Icons.person_outline_rounded,
                      errorText: controller.lastNameError.value,
                      action: TextInputAction.next,
                      onSubmitted: () => _firstNameFocus.requestFocus(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      fieldKey: 'firstName',
                      ctrl: _firstNameCtrl,
                      focus: _firstNameFocus,
                      hint: 'Tên',
                      icon: Icons.person_outline_rounded,
                      errorText: controller.firstNameError.value,
                      action: TextInputAction.next,
                      onSubmitted: () => _emailFocus.requestFocus(),
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 16),

          // Email
          Obx(() => _buildField(
                fieldKey: 'email',
                ctrl: _emailCtrl,
                focus: _emailFocus,
                hint: 'Email',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                errorText: controller.emailError.value,
                action: TextInputAction.next,
                onSubmitted: () => _phoneFocus.requestFocus(),
              )),
          const SizedBox(height: 16),

          // Số điện thoại
          Obx(() => _buildField(
                fieldKey: 'phone',
                ctrl: _phoneCtrl,
                focus: _phoneFocus,
                hint: 'Số điện thoại',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                errorText: controller.phoneError.value,
                action: TextInputAction.next,
                onSubmitted: () => _passwordFocus.requestFocus(),
              )),
          const SizedBox(height: 16),

          // Ngày sinh
          Obx(() => _buildField(
                fieldKey: 'dob',
                ctrl: _dobCtrl,
                focus: _dobFocus,
                hint: 'Ngày sinh (dd/mm/yyyy)',
                icon: Icons.calendar_today_outlined,
                errorText: controller.dobError.value,
                readOnly: true,
                onTap: _selectDate,
                suffix: const Icon(Icons.arrow_drop_down_rounded,
                    color: AppColors.emerald),
              )),
          const SizedBox(height: 16),

          // Mật khẩu
          Obx(() => _buildField(
                fieldKey: 'password',
                ctrl: _passwordCtrl,
                focus: _passwordFocus,
                hint: 'Mật khẩu',
                icon: Icons.lock_outline_rounded,
                obscureText: !controller.isPasswordVisible.value,
                errorText: controller.passwordError.value,
                action: TextInputAction.next,
                onSubmitted: () => _confirmPasswordFocus.requestFocus(),
                suffix: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: AppColors.emerald.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  onPressed: controller.togglePassword,
                ),
              )),

          if (_passwordCtrl.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildPasswordStrength(_passwordCtrl.text),
          ],
          const SizedBox(height: 16),

          // Xác nhận mật khẩu
          Obx(() => _buildField(
                fieldKey: 'confirmPassword',
                ctrl: _confirmPasswordCtrl,
                focus: _confirmPasswordFocus,
                hint: 'Nhập lại mật khẩu',
                icon: Icons.lock_outline_rounded,
                obscureText: !controller.isConfirmPasswordVisible.value,
                errorText: controller.confirmPasswordError.value,
                action: TextInputAction.done,
                onSubmitted: _submitRegister,
                suffix: IconButton(
                  icon: Icon(
                    controller.isConfirmPasswordVisible.value
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: AppColors.emerald.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  onPressed: controller.toggleConfirmPassword,
                ),
              )),
          const SizedBox(height: 20),

          _buildTermsCheckbox(),
          const SizedBox(height: 24),

          _buildRegisterButton(),
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
    String errorText = '',
    bool obscureText = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    int? maxLength,
    VoidCallback? onSubmitted,
    VoidCallback? onTap,
    Widget? suffix,
  }) {
    final isFocused = focus.hasFocus;
    final localValid = _fieldValid[fieldKey];
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
              readOnly: readOnly,
              keyboardType: keyboardType,
              textInputAction: action,
              maxLength: maxLength,
              onTap: onTap,
              onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
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
                counterText: '',
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
      ),
    );
  }

  Widget _buildPasswordStrength(String pw) {
    final s = _passwordStrength(pw);
    final Color color;
    final String label;
    final double fraction;

    if (s <= 2) {
      color = AppColors.errorRed;
      label = 'Yếu';
      fraction = 0.33;
    } else if (s <= 3) {
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
            Text('Độ mạnh mật khẩu',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textGrey)),
            Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: color, fontWeight: FontWeight.w700)),
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

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: _agreedToTerms ? AppColors.emerald : AppColors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: _agreedToTerms ? AppColors.emerald : AppColors.grey400,
                width: 1.5,
              ),
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check_rounded,
                    size: 14, color: AppColors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textGrey, height: 1.5),
                children: [
                  const TextSpan(text: 'Tôi đồng ý với '),
                  TextSpan(
                    text: 'Điều khoản dịch vụ',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.emerald, fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' của FoodHit Admin'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return LayoutBuilder(
      builder: (_, constraints) {
        final isIdle = _btnState == _BtnState.idle;
        final isSuccess = _btnState == _BtnState.success;
        final canSubmit = _agreedToTerms && isIdle;

        return GestureDetector(
          onTap: canSubmit ? _submitRegister : null,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: isIdle ? constraints.maxWidth : 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: isIdle && _agreedToTerms
                    ? const LinearGradient(
                        colors: [
                          AppColors.emeraldDark,
                          AppColors.emerald,
                          AppColors.emeraldLight,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: isSuccess
                    ? AppColors.emerald
                    : isIdle && !_agreedToTerms
                        ? AppColors.grey300
                        : AppColors.grey400,
                borderRadius: BorderRadius.circular(28),
                boxShadow: (isIdle && _agreedToTerms) || isSuccess
                    ? [
                        BoxShadow(
                          color: AppColors.emerald.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isIdle
                    ? Row(
                        key: const ValueKey('idle'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add_rounded,
                            color: _agreedToTerms
                                ? AppColors.white
                                : AppColors.grey600,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Tạo tài khoản',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _agreedToTerms
                                  ? AppColors.white
                                  : AppColors.grey600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      )
                    : isSuccess
                        ? const Icon(
                            key: ValueKey('success'),
                            Icons.check_rounded,
                            color: AppColors.white,
                            size: 28,
                          )
                        : const SizedBox(
                            key: ValueKey('loading'),
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Đã có tài khoản? ',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
          GestureDetector(
            onTap: Get.back,
            child: Text(
              'Đăng nhập ngay',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.emerald, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
