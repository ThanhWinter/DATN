import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/notification_controller.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_tile.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

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
          TextButton(
            onPressed: controller.markAllAsRead,
            child: Text(
              'Đọc tất cả',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        isEmpty: () => controller.notifications.isEmpty,
        emptyWidget: const NotificationEmptyState(),
        onSuccess: () => ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.notifications.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: AppColors.grey300),
          itemBuilder: (_, index) {
            final notif = controller.notifications[index];
            return NotificationTile(
              notif: notif,
              onMarkAsRead: () => controller.markAsRead(notif.id),
              onDelete: () => controller.deleteNotification(notif.id),
            );
          },
        ),
      ),
    );
  }
}
