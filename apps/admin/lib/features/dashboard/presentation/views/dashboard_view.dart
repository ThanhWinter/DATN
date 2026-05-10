import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/stat_card_widget.dart';
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
      backgroundColor: AppColors.mintBg,
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onSuccess: () => RefreshIndicator(
          onRefresh: controller.loadDashboard,
          color: AppColors.emerald,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.mintBg,
                elevation: 0,
                expandedHeight: 80,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  title: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.emerald, AppColors.emeraldLight],
                    ).createShader(bounds),
                    child: const Text(
                      'Thống kê',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  background: Container(color: AppColors.mintBg),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Stats hôm nay ─────────────────────────────────────
                    const _SectionHeader(label: 'Hôm nay'),
                    const SizedBox(height: 12),
                    Obx(() => Row(
                          children: [
                            StatCardWidget(
                              label: 'Đơn hàng',
                              value: '${controller.stats.value.todayOrders}',
                              icon: Icons.receipt_long_rounded,
                              color: AppColors.emerald,
                              useGradient: true,
                            ),
                            const SizedBox(width: 10),
                            StatCardWidget(
                              label: 'Doanh thu',
                              value: _fmtRevenue(
                                  controller.stats.value.todayRevenue),
                              icon: Icons.trending_up_rounded,
                              color: AppColors.emeraldDark,
                              useGradient: true,
                            ),
                            const SizedBox(width: 10),
                            StatCardWidget(
                              label: 'Món ăn',
                              value: '${controller.stats.value.totalFoods}',
                              icon: Icons.restaurant_menu_rounded,
                              color: AppColors.emerald,
                              useGradient: true,
                            ),
                          ],
                        )),
                    const SizedBox(height: 28),

                    // ── Xuất báo cáo ─────────────────────────────────────
                    const _SectionHeader(label: 'Xuất báo cáo'),
                    const SizedBox(height: 4),
                    Text(
                      'Chọn ngày và xuất file Excel để gửi hoặc lưu trữ.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 14),
                    _ExportCard(controller: controller),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.emerald, AppColors.emeraldLight],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: AppTextStyles.h3.copyWith(color: AppColors.textDark)),
      ],
    );
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard({required this.controller});
  final DashboardController controller;

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
            primary: AppColors.emerald,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) controller.exportRevenue(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.emerald.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.table_chart_rounded,
                  color: AppColors.emerald,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Báo cáo Excel', style: AppTextStyles.bodyLarge),
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
                height: 48,
                child: controller.isExporting.value
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppColors.grey300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      )
                    : Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.emeraldDark,
                                AppColors.emerald,
                                AppColors.emeraldLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _pickAndExport(context),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download_rounded,
                                    color: AppColors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Chọn ngày & Xuất Excel',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              )),
        ],
      ),
    );
  }
}
