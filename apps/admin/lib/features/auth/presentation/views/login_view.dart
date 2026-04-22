import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  LoginView({super.key});

  final _emailCtrl = TextEditingController(text: 'admin@foodhit.vn');
  final _passwordCtrl = TextEditingController(text: '123456');
  final _obscure = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header orange ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 48,
                bottom: 40,
              ),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 44,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FoodHit Admin',
                    style: AppTextStyles.h2.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quản lý cửa hàng của bạn',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ─────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text('Đăng nhập', style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  const Text('Chỉ dành cho quản trị viên',
                      style: AppTextStyles.bodySmall),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscure.value,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.grey600,
                        ),
                        onPressed: () => _obscure.value = !_obscure.value,
                      ),
                    ),
                  )),
                  const SizedBox(height: 8),
                  Obx(() => controller.errorMessage.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 16, color: AppColors.errorRed),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.errorRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink()),
                  const SizedBox(height: 28),
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Đăng nhập',
                      isLoading: controller.isLoading.value,
                      onPressed: () => controller.login(
                        email: _emailCtrl.text.trim(),
                        password: _passwordCtrl.text.trim(),
                      ),
                    ),
                  )),
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      'FoodHit © 2025',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
