import 'package:core_ui/core_ui.dart';
import 'package:core_utils/core_utils.dart';
import 'package:flutter/material.dart';

import '../../data/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notif,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notif.isRead
          ? AppColors.white
          : AppColors.primaryOrange.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onMarkAsRead,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconBadge(),
              const SizedBox(width: 12),
              Expanded(child: _buildContent()),
              _buildPopupMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBadge() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _iconBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(_icon, color: _iconColor, size: 24),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                  fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          notif.message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          formatRelativeTime(notif.timestamp),
          style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'read') onMarkAsRead();
        if (value == 'delete') onDelete();
      },
      icon: const Icon(Icons.more_horiz, color: AppColors.grey600, size: 20),
      padding: EdgeInsets.zero,
      itemBuilder: (_) => [
        const PopupMenuItem<String>(
          value: 'read',
          child: Row(
            children: [
              Icon(Icons.mark_email_read_outlined,
                  size: 18, color: AppColors.primaryOrange),
              SizedBox(width: 10),
              Text('Đánh dấu đã đọc', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline,
                  size: 18, color: AppColors.errorRed),
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
    );
  }

  IconData get _icon {
    switch (notif.type) {
      case 'order':
        return Icons.receipt_long_rounded;
      case 'system':
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color get _iconColor {
    switch (notif.type) {
      case 'order':
        return AppColors.primaryOrangeDark;
      case 'system':
      default:
        return AppColors.grey600;
    }
  }

  Color get _iconBackgroundColor {
    switch (notif.type) {
      case 'order':
        return AppColors.primaryOrange.withValues(alpha: 0.15);
      case 'system':
      default:
        return AppColors.grey300;
    }
  }
}
