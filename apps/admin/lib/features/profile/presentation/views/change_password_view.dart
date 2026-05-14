import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Đổi mật khẩu', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Obx(() => _PasswordField(
                        label: 'Mật khẩu mới',
                        controller: controller.newPasswordCtrl,
                        obscure: !controller.showNew.value,
                        onToggle: () => controller.showNew.toggle(),
                      )),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Obx(() => _PasswordField(
                        label: 'Xác nhận',
                        controller: controller.confirmCtrl,
                        obscure: !controller.showConfirm.value,
                        onToggle: () => controller.showConfirm.toggle(),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Mật khẩu cần 8–16 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt (@\$!%*?&).',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textGrey),
              ),
            ),
            const SizedBox(height: 28),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        controller.isSaving.value ? null : controller.save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor:
                          AppColors.primaryOrange.withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: controller.isSaving.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.white),
                          )
                        : const Text('Đổi mật khẩu',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textGrey)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: AppTextStyles.labelLarge,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.grey600,
                  ),
                  onPressed: onToggle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
