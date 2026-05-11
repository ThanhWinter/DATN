import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../data/models/admin_notification_model.dart';
import '../controllers/notification_list_controller.dart';

class NotificationListView extends GetView<NotificationListController> {
  const NotificationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Thông báo', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Obx(() {
            if (!controller.hasUnread.value) return const SizedBox.shrink();
            return TextButton(
              onPressed: controller.isMarkingAll.value
                  ? null
                  : controller.markAllAsRead,
              child: Text(
                'Đọc tất cả',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onRefresh: controller.loadNotifications,
        onSuccess: () => RefreshIndicator(
          onRefresh: controller.loadNotifications,
          color: AppColors.primaryOrange,
          child: Obx(() {
            if (controller.notifications.isEmpty) {
              return const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: AppEmptyState(
                      icon: Icons.notifications_none_outlined,
                      message: 'Chưa có thông báo nào',
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: controller.notifications.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (_, i) {
                final notif = controller.notifications[i];
                return _NotifTile(
                  notif: notif,
                  onTap: () {
                    controller.markAsRead(notif);
                    if (notif.orderId != null) {
                      Get.toNamed(
                        AppRoutes.orderDetail,
                        arguments: notif.orderId,
                      );
                    }
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif, required this.onTap});

  final AdminNotificationModel notif;
  final VoidCallback onTap;

  String _fmtTime(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notif.isRead;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread
            ? AppColors.primaryOrange.withValues(alpha: 0.04)
            : AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: unread
                    ? AppColors.primaryOrange.withValues(alpha: 0.12)
                    : AppColors.grey200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 20,
                color: unread ? AppColors.primaryOrange : AppColors.grey600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight:
                                unread ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notif.body,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textGrey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _fmtTime(notif.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey400,
                      fontSize: 11,
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
