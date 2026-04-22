import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.message,
    this.subMessage,
    super.key,
  });

  final IconData icon;
  final String message;
  final String? subMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: AppColors.grey300),
          const SizedBox(height: 14),
          Text(message, style: AppTextStyles.bodyLarge),
          if (subMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              subMessage!,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
