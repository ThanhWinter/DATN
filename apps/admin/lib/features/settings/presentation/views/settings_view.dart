import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Cài đặt', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onSuccess: () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Banner navigation ───────────────────────────────────────
              _NavCard(
                icon: Icons.image_outlined,
                label: 'Quản lý Banner quảng cáo',
                subtitle: 'Thêm, sửa, xoá và bật/tắt banner hiển thị cho khách',
                onTap: () => Get.toNamed(AppRoutes.banners),
              ),
              const SizedBox(height: 16),

              // ── Store status ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trạng thái cửa hàng', style: AppTextStyles.h3),
                          SizedBox(height: 4),
                          Text('Bật/tắt nhận đơn hàng mới',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Obx(() => Switch(
                          value: controller.isOpen.value,
                          onChanged: (v) => controller.isOpen.value = v,
                          activeThumbColor: AppColors.successGreen,
                          activeTrackColor:
                              AppColors.successGreen.withValues(alpha: 0.4),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Store info form ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thông tin cửa hàng', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    _FormField(
                      label: 'Tên cửa hàng',
                      ctrl: controller.storeNameCtrl,
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      label: 'Hotline',
                      ctrl: controller.hotlineCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      label: 'Phí giao cơ bản (₫)',
                      ctrl: controller.shippingFeeCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      label: 'Miễn phí ship từ (₫)',
                      ctrl: controller.freeShipCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Save button ─────────────────────────────────────────────
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.saveStoreSetting,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        disabledBackgroundColor: AppColors.grey300,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.white),
                            )
                          : const Text('Lưu cài đặt',
                              style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Navigation Card ───────────────────────────────────────────────────────────

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryOrange, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textGrey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textLight, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Form Field ────────────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.ctrl,
    this.keyboardType,
  });

  final String label;
  final TextEditingController ctrl;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      style: AppTextStyles.bodyMedium,
    );
  }
}
