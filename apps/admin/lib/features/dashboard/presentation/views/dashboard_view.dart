import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  String _fmtRevenue(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Thống kê', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onSuccess: () => RefreshIndicator(
          onRefresh: controller.loadDashboard,
          color: AppColors.primaryOrange,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Stats hôm nay ─────────────────────────────────────────
                const Text('Hôm nay', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                Obx(() => Row(
                      children: [
                        _StatCard(
                          label: 'Đơn hàng',
                          value: '${controller.stats.value.todayOrders}',
                          icon: Icons.receipt_outlined,
                          color: AppColors.primaryOrange,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Doanh thu',
                          value: _fmtRevenue(
                              controller.stats.value.todayRevenue),
                          icon: Icons.trending_up,
                          color: AppColors.successGreen,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Món ăn',
                          value: '${controller.stats.value.totalFoods}',
                          icon: Icons.restaurant_menu_outlined,
                          color: Colors.blueAccent,
                        ),
                      ],
                    )),
                const SizedBox(height: 28),

                // ── Xuất báo cáo ─────────────────────────────────────────
                const Text('Xuất báo cáo doanh thu', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(
                  'Chọn ngày và xuất file Excel để gửi hoặc lưu trữ.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textGrey),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.table_chart_outlined,
                              color: AppColors.primaryOrange,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Báo cáo Excel',
                                    style: AppTextStyles.bodyLarge),
                                SizedBox(height: 2),
                                Text(
                                  'Doanh thu theo ngày — định dạng .xlsx',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: controller.isExporting.value
                                  ? null
                                  : () => _pickAndExport(context),
                              icon: controller.isExporting.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : const Icon(Icons.download_outlined,
                                      color: AppColors.white),
                              label: Text(
                                controller.isExporting.value
                                    ? 'Đang xuất...'
                                    : 'Chọn ngày & Xuất Excel',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryOrange,
                                disabledBackgroundColor: AppColors.grey300,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndExport(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'Chọn ngày cần xuất báo cáo',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryOrange,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) controller.exportRevenue(picked);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(color: color, fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
