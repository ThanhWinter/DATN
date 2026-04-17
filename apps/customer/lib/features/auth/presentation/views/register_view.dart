import "package:core_ui/core_ui.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

import "../controllers/register_controller.dart";

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

  @override
  void initState() {
    super.initState();
    controller = Get.find<RegisterController>();
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
                // Custom AppBar với nút back
                _buildAppBar(),

                // Form cuộn được
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // ── Tiêu đề ─────────────────────────────────────────
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

                        // ── Phụ đề ──────────────────────────────────────────
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
                                    child: GlassInputField(
                                      controller: _lastNameCtrl,
                                      hintText: "Họ",
                                      icon: Icons.person_outline,
                                    ),
                                    errorText: controller.lastNameError.value,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInputSection(
                                    child: GlassInputField(
                                      controller: _firstNameCtrl,
                                      hintText: "Tên",
                                      icon: Icons.person_outline,
                                    ),
                                    errorText: controller.firstNameError.value,
                                  ),
                                ),
                              ],
                            )),

                        const SizedBox(height: 16),

                        // ── Email ─────────────────────────────────────────────
                        Obx(() => _buildInputSection(
                              child: GlassInputField(
                                controller: _emailCtrl,
                                hintText: "Email",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              errorText: controller.emailError.value,
                            )),

                        const SizedBox(height: 16),

                        // ── Số điện thoại ─────────────────────────────────────
                        Obx(() => _buildInputSection(
                              child: GlassInputField(
                                controller: _phoneCtrl,
                                hintText: "Số điện thoại",
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                              ),
                              errorText: controller.phoneError.value,
                            )),

                        const SizedBox(height: 16),

                        // ── Ngày sinh ─────────────────────────────────────────
                        Obx(() => _buildInputSection(
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
                            )),

                        const SizedBox(height: 16),

                        // ── Mật khẩu ──────────────────────────────────────────
                        Obx(() => _buildInputSection(
                              child: GlassInputField(
                                controller: _passwordCtrl,
                                hintText: "Mật khẩu",
                                icon: Icons.lock_outline,
                                obscureText: !controller.isPasswordVisible.value,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color:
                                        AppColors.white.withValues(alpha: 0.7),
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
                              child: GlassInputField(
                                controller: _confirmPasswordCtrl,
                                hintText: "Nhập lại mật khẩu",
                                icon: Icons.lock_outline,
                                obscureText:
                                    !controller.isConfirmPasswordVisible.value,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isConfirmPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color:
                                        AppColors.white.withValues(alpha: 0.7),
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
                color: AppColors.accentGold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
