import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core_ui/core_ui.dart';

import '../controllers/notification_controller.dart';
import '../../data/models/notification_model.dart';

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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          );
        }

        if (controller.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: AppColors.grey300,
                ),
                SizedBox(height: 16),
                Text(
                  'Bạn chưa có thông báo nào',
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.notifications.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: AppColors.grey300),
          itemBuilder: (_, index) {
            final notification = controller.notifications[index];
            return _buildNotificationTile(notification);
          },
        );
      }),
    );
  }

  Widget _buildNotificationTile(NotificationModel notif) {
    return Material(
      color: notif.isRead
          ? AppColors.white
          : AppColors.primaryOrange.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () => controller.markAsRead(notif.id),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon type badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(notif.type),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(notif.type),
                  color: _getIconColor(notif.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Nội dung thông báo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Chấm tròn chưa đọc
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6, top: 2),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            notif.title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: notif.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textGrey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(notif.timestamp),
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Menu "..." nằm ngang
              PopupMenuButton<String>(
                onSelected: (value) => _onMenuSelected(value, notif),
                icon: const Icon(
                  Icons.more_horiz,
                  color: AppColors.grey600,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                itemBuilder: (_) => [
                  const PopupMenuItem<String>(
                    value: 'read',
                    child: Row(
                      children: [
                        Icon(
                          Icons.mark_email_read_outlined,
                          size: 18,
                          color: AppColors.primaryOrange,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Đánh dấu đã đọc',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.errorRed,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Xoá thông báo',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.errorRed),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onMenuSelected(String value, NotificationModel notif) {
    switch (value) {
      case 'read':
        controller.markAsRead(notif.id);
        break;
      case 'delete':
        controller.deleteNotification(notif.id);
        break;
    }
  }

  // --- Helpers ---

  IconData _getIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.receipt_long_rounded;
      case 'promo':
        return Icons.local_activity_rounded;
      case 'system':
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'order':
        return AppColors.primaryOrangeDark;
      case 'promo':
        return AppColors.errorRed;
      case 'system':
      default:
        return AppColors.grey600;
    }
  }

  Color _getIconBackgroundColor(String type) {
    switch (type) {
      case 'order':
        return AppColors.primaryOrange.withValues(alpha: 0.15);
      case 'promo':
        return AppColors.errorRed.withValues(alpha: 0.15);
      case 'system':
      default:
        return AppColors.grey300;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month lúc $hour:$minute';
    }
  }
}
