import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
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
          Text('Bạn chưa có thông báo nào', style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}
