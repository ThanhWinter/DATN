import 'package:core_ui/core_ui.dart';
import 'package:core_utils/core_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../data/models/notification_model.dart';
import '../controllers/notification_controller.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_tile.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  late final NotificationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<NotificationController>();
    controller.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Thông báo', style: AppTextStyles.h2),
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          Obx(() => controller.unreadCount.value > 0
              ? TextButton(
                  onPressed: controller.markAllAsRead,
                  child: Text(
                    'Đọc tất cả',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : const SizedBox.shrink()),
          const SizedBox(width: 8),
        ],
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        onSuccess: () => RefreshIndicator(
          onRefresh: controller.loadNotifications,
          color: AppColors.primaryOrange,
          child: Obx(() => controller.notifications.isEmpty
              ? const CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(child: NotificationEmptyState()),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.notifications.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.grey300),
                  itemBuilder: (_, index) {
                    final notif = controller.notifications[index];
                    return RepaintBoundary(
                      child: NotificationTile(
                        notif: notif,
                        onMarkAsRead: () => controller.markAsRead(notif.id),
                        onDelete: () => controller.deleteNotification(notif.id),
                        onTap: () {
                          controller.markAsRead(notif.id);
                          Get.bottomSheet(
                            _NotificationDetailSheet(notif: notif),
                            backgroundColor: AppColors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            isScrollControlled: true,
                          );
                        },
                      ),
                    );
                  },
                )),
        ),
      ),
    );
  }
}

// ── Notification Detail Sheet ─────────────────────────────────────────────────

class _NotificationDetailSheet extends StatelessWidget {
  const _NotificationDetailSheet({required this.notif});

  final NotificationModel notif;

  @override
  Widget build(BuildContext context) {
    final isOrder = notif.type == 'order';
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 12,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Icon badge
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isOrder
                  ? AppColors.primaryOrange.withValues(alpha: 0.15)
                  : AppColors.grey300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOrder
                  ? Icons.receipt_long_rounded
                  : Icons.info_outline_rounded,
              color:
                  isOrder ? AppColors.primaryOrangeDark : AppColors.grey600,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          // Type badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isOrder
                  ? AppColors.primaryOrange.withValues(alpha: 0.1)
                  : AppColors.grey200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOrder ? 'Đơn hàng' : 'Hệ thống',
              style: AppTextStyles.bodySmall.copyWith(
                color: isOrder
                    ? AppColors.primaryOrangeDark
                    : AppColors.textGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Title
          Text(
            notif.title,
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          // Timestamp
          Text(
            formatOrderDate(notif.timestamp),
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textGrey),
          ),
          const Divider(height: 28),
          // Full message
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                notif.message,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),
          // Navigate to order button
          if (isOrder && notif.orderId != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.orderDetail,
                      arguments: notif.orderId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Xem đơn hàng',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
