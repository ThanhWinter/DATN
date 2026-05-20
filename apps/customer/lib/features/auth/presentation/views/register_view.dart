import "package:core_ui/core_ui.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

import "../controllers/register_controller.dart";
import "../widgets/auth_loading_overlay.dart";

// Keep consistent with backend regex in RegisterUserRequest.java.
const _passwordRegex =
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,16}$';

/// Màn hình Đăng ký tài khoản — mirror UI của SignUpScreen trong fo_mobile,
/// được điều chỉnh theo design system orange/gold của food_hit.
///
/// Dùng StatefulWidget để quản lý lifecycle của TextEditingControllers (Rule 10).
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

  late final PageController _pageController;
  // UI hiện tại không dùng wizard nữa, nhưng code cũ vẫn còn để bạn quay lại nhanh nếu cần.
  // ignore: prefer_final_fields
  int _step = 0;

  final _lastNameFocus = FocusNode();
  final _firstNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = Get.find<RegisterController>();
    _pageController = PageController(initialPage: _step);
  }

  @override
  void dispose() {
    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _pageController.dispose();
    _lastNameFocus.dispose();
    _firstNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryOrange,
            onPrimary: AppColors.white,
            onSurface: AppColors.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.setDob(picked);
      _dobCtrl.text = _formatDate(picked);
    }
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, "0");
    final m = date.month.toString().padLeft(2, "0");
    return "$d/$m/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background Image ──────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/register_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const ColoredBox(color: AppColors.primaryOrangeDark);
              },
            ),
          ),
          // Dark overlay để chữ rõ
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xB3000000),
                    Color(0x66000000),
                    Color(0x32000000),
                  ],
                ),
              ),
            ),
          ),

          // ── Nội dung chính ─────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom AppBar với nút back
                _buildAppBar(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        Text(
                          "Tạo tài khoản mới",
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
                          "Vui lòng điền thông tin bên dưới",
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Hàng Họ / Tên ────────────────────────────────────
                        Obx(() => Row(
                              children: [
                                Expanded(
                                  child: _buildInputSection(
                                    child: _OutlinedGlassInputField(
                                      controller: _lastNameCtrl,
                                      focusNode: _lastNameFocus,
                                      hintText: "Họ",
                                      icon: Icons.person_outline,
                                      textInputAction: TextInputAction.next,
                                      onSubmitted: () =>
                                          _firstNameFocus.requestFocus(),
                                    ),
                                    errorText: controller.lastNameError.value,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInputSection(
                                    child: _OutlinedGlassInputField(
                                      controller: _firstNameCtrl,
                                      focusNode: _firstNameFocus,
                                      hintText: "Tên",
                                      icon: Icons.person_outline,
                                      textInputAction: TextInputAction.next,
                                      onSubmitted: () =>
                                          _emailFocus.requestFocus(),
                                    ),
                                    errorText: controller.firstNameError.value,
                                  ),
                                ),
                              ],
                            )),

                        const SizedBox(height: 16),

                        // ── Email ─────────────────────────────────────────────
                        Obx(() => _buildInputSection(
                              child: _OutlinedGlassInputField(
                                controller: _emailCtrl,
                                focusNode: _emailFocus,
                                hintText: "Email",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onSubmitted: () => _phoneFocus.requestFocus(),
                              ),
                              errorText: controller.emailError.value,
                            )),

                        const SizedBox(height: 16),

                        // ── Số điện thoại ─────────────────────────────────────
                        Obx(() => _buildInputSection(
                              child: _OutlinedGlassInputField(
                                controller: _phoneCtrl,
                                focusNode: _phoneFocus,
                                hintText: "Số điện thoại",
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                textInputAction: TextInputAction.next,
                                onSubmitted: () =>
                                    _passwordFocus.requestFocus(),
                              ),
                              errorText: controller.phoneError.value,
                            )),

                        const SizedBox(height: 16),

                        // ── Ngày sinh ─────────────────────────────────────────
                        Obx(() => _buildInputSection(
                              child: _OutlinedGlassInputField(
                                controller: _dobCtrl,
                                hintText: "Ngày sinh (dd/mm/yyyy)",
                                icon: Icons.calendar_today_outlined,
                                readOnly: true,
                                onTap: _selectDate,
                                suffixIcon: const Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: AppColors.white,
                                ),
                              ),
                              errorText: controller.dobError.value,
                            )),

                        const SizedBox(height: 16),

                        // ── Mật khẩu ──────────────────────────────────────────
                        Obx(() => _buildInputSection(
                              child: _OutlinedGlassInputField(
                                controller: _passwordCtrl,
                                focusNode: _passwordFocus,
                                hintText: "Mật khẩu",
                                icon: Icons.lock_outline,
                                obscureText:
                                    !controller.isPasswordVisible.value,
                                textInputAction: TextInputAction.next,
                                onSubmitted: () =>
                                    _confirmPasswordFocus.requestFocus(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppColors.white,
                                    size: 22,
                                  ),
                                  onPressed: controller.togglePassword,
                                ),
                              ),
                              errorText: controller.passwordError.value,
                            )),

                        const SizedBox(height: 16),

                        // ── Nhập lại mật khẩu ─────────────────────────────────
                        Obx(() => _buildInputSection(
                              child: _OutlinedGlassInputField(
                                controller: _confirmPasswordCtrl,
                                focusNode: _confirmPasswordFocus,
                                hintText: "Nhập lại mật khẩu",
                                icon: Icons.lock_outline,
                                obscureText:
                                    !controller.isConfirmPasswordVisible.value,
                                textInputAction: TextInputAction.done,
                                onSubmitted: () => controller.signUp(
                                  firstName: _firstNameCtrl.text,
                                  lastName: _lastNameCtrl.text,
                                  email: _emailCtrl.text,
                                  phone: _phoneCtrl.text,
                                  password: _passwordCtrl.text,
                                  confirmPassword: _confirmPasswordCtrl.text,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isConfirmPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppColors.white,
                                    size: 22,
                                  ),
                                  onPressed: controller.toggleConfirmPassword,
                                ),
                              ),
                              errorText: controller.confirmPasswordError.value,
                            )),

                        const SizedBox(height: 40),

                        // ── Nút Đăng ký ───────────────────────────────────────
                        Obx(
                          () => GradientActionButton(
                            icon: Icons.person_add_outlined,
                            iconColor: AppColors.primaryOrange,
                            text: "Đăng Ký",
                            isPrimary: true,
                            onTap: controller.isLoading.value
                                ? () {}
                                : () => controller.signUp(
                                      firstName: _firstNameCtrl.text,
                                      lastName: _lastNameCtrl.text,
                                      email: _emailCtrl.text,
                                      phone: _phoneCtrl.text,
                                      password: _passwordCtrl.text,
                                      confirmPassword:
                                          _confirmPasswordCtrl.text,
                                    ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          AuthLoadingOverlay(isLoading: controller.isLoading),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tạo tài khoản mới",
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
          "Điền lần lượt các bước sau để đăng ký",
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildDots() {
    const count = 7;
    return Row(
      children: List.generate(
        count,
        (i) => Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: i == _step
                  ? AppColors.primaryOrange
                  : AppColors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ),
    );
  }

  void _goToStep(int target) {
    if (target < 0 || target > 6) return;
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  bool _isStepValid(int step) {
    switch (step) {
      case 0:
        return _lastNameCtrl.text.trim().isNotEmpty &&
            _firstNameCtrl.text.trim().isNotEmpty;
      case 1:
        return GetUtils.isEmail(_emailCtrl.text.trim());
      case 2:
        return _phoneCtrl.text.trim().length >= 10;
      case 3:
        return controller.selectedDob.value != null;
      case 4:
        return RegExp(_passwordRegex).hasMatch(_passwordCtrl.text);
      case 5:
        return _confirmPasswordCtrl.text.isNotEmpty &&
            _confirmPasswordCtrl.text == _passwordCtrl.text;
      case 6:
        return true;
      default:
        return false;
    }
  }

  void _handleRegister() {
    // Navigate to the first invalid step so user sees the correct field.
    if (!_isStepValid(0)) return _goToStep(0);
    if (!_isStepValid(1)) return _goToStep(1);
    if (!_isStepValid(2)) return _goToStep(2);
    if (!_isStepValid(3)) return _goToStep(3);
    if (!_isStepValid(4)) return _goToStep(4);
    if (!_isStepValid(5)) return _goToStep(5);

    FocusScope.of(context).unfocus();
    controller.signUp(
      firstName: _firstNameCtrl.text,
      lastName: _lastNameCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      password: _passwordCtrl.text,
      confirmPassword: _confirmPasswordCtrl.text,
    );
  }

  // ignore: unused_element
  Widget _buildNavigationButtons() {
    final isFirst = _step == 0;
    final isLast = _step == 6;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isFirst ? null : () => _goToStep(_step - 1),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.white,
              side: BorderSide(color: AppColors.white.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Trở lại",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Obx(
            () => ElevatedButton(
              onPressed: (controller.isLoading.value || isLast)
                  ? null
                  : (_isStepValid(_step) ? () => _goToStep(_step + 1) : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.white.withValues(alpha: 0.2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isLast ? " " : "Tiếp theo",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildStepName() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildInputSection(
                child: GlassInputField(
                  controller: _lastNameCtrl,
                  focusNode: _lastNameFocus,
                  hintText: "Họ",
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  onSubmitted: () => _firstNameFocus.requestFocus(),
                ),
                errorText: controller.lastNameError.value,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputSection(
                child: GlassInputField(
                  controller: _firstNameCtrl,
                  focusNode: _firstNameFocus,
                  hintText: "Tên",
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  onSubmitted: () => _emailFocus.requestFocus(),
                ),
                errorText: controller.firstNameError.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildStepEmail() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Obx(
        () => _buildInputSection(
          child: GlassInputField(
            controller: _emailCtrl,
            focusNode: _emailFocus,
            hintText: "Email",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onSubmitted: () => _phoneFocus.requestFocus(),
          ),
          errorText: controller.emailError.value,
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildStepPhone() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Obx(
        () => _buildInputSection(
          child: GlassInputField(
            controller: _phoneCtrl,
            focusNode: _phoneFocus,
            hintText: "Số điện thoại",
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            textInputAction: TextInputAction.next,
            onSubmitted: () {
              _goToStep(3);
              // Let the page animate first, then show date picker.
              Future.delayed(const Duration(milliseconds: 260), _selectDate);
            },
          ),
          errorText: controller.phoneError.value,
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildStepDob() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Obx(
        () => _buildInputSection(
          child: GlassInputField(
            controller: _dobCtrl,
            hintText: "Ngày sinh (dd/mm/yyyy)",
            icon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: _selectDate,
            suffixIcon: Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          errorText: controller.dobError.value,
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildStepPassword() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Obx(
        () => _buildInputSection(
          child: GlassInputField(
            controller: _passwordCtrl,
            focusNode: _passwordFocus,
            hintText: "Mật khẩu",
            icon: Icons.lock_outline,
            obscureText: !controller.isPasswordVisible.value,
            textInputAction: TextInputAction.next,
            onSubmitted: () => _confirmPasswordFocus.requestFocus(),
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
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildStepConfirmPassword() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Obx(
        () => _buildInputSection(
          child: GlassInputField(
            controller: _confirmPasswordCtrl,
            focusNode: _confirmPasswordFocus,
            hintText: "Nhập lại mật khẩu",
            icon: Icons.lock_outline,
            obscureText: !controller.isConfirmPasswordVisible.value,
            textInputAction: TextInputAction.done,
            onSubmitted: () => _goToStep(6),
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
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildStepSubmit() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Xác nhận & đăng ký",
              style: AppTextStyles.h1.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Bấm đăng ký để hệ thống gửi OTP qua email cho bạn.",
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 20),
            _buildSummaryLine("Họ tên",
                "${_lastNameCtrl.text} ${_firstNameCtrl.text}".trim()),
            _buildSummaryLine("Email", _emailCtrl.text.trim()),
            _buildSummaryLine("SĐT", _phoneCtrl.text.trim()),
            _buildSummaryLine("Ngày sinh", _dobCtrl.text.trim()),
            const SizedBox(height: 18),
            Obx(
              () => GradientActionButton(
                icon: Icons.person_add_outlined,
                iconColor: AppColors.primaryOrange,
                text:
                    controller.isLoading.value ? "Đang đăng ký..." : "Đăng ký",
                isPrimary: true,
                onTap: controller.isLoading.value ? () {} : _handleRegister,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "—",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets cục bộ ──────────────────────────────────────────────────────────

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
            child: Text(
              errorText,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Input chỉ dùng riêng cho màn đăng ký: trong suốt nhưng nổi viền + chữ.
/// Mục tiêu: giống style nút "Đăng ký tài khoản mới" (outline) ở màn Login.
class _OutlinedGlassInputField extends StatelessWidget {
  const _OutlinedGlassInputField({
    required this.controller,
    required this.hintText,
    this.icon,
    this.obscureText = false,
    this.readOnly = false,
    this.suffixIcon,
    this.keyboardType,
    this.onTap,
    this.maxLength,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final bool obscureText;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final int? maxLength;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.7),
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        maxLength: maxLength,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted != null ? (_) => onSubmitted!() : null,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: AppColors.primaryOrange,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.white.withValues(alpha: 0.75),
          ),
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: AppColors.white.withValues(alpha: 0.85),
                  size: 22,
                )
              : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          counterText: "",
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    );
  }
}
