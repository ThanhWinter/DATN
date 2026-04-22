import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Card chứa danh sách menu items, có shadow nhẹ.
class AppMenuCard extends StatelessWidget {
  const AppMenuCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

/// Menu item với icon box, label và trailing widget.
class AppMenuTile extends StatelessWidget {
  const AppMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor != null
                    ? iconColor!.withValues(alpha: 0.1)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: iconColor ?? AppColors.textGrey, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(color: labelColor),
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.grey400, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Divider dùng giữa các AppMenuTile.
class AppMenuDivider extends StatelessWidget {
  const AppMenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppColors.grey300),
    );
  }
}

/// Badge màu cam hiển thị số lượng (thông báo, đơn hàng...).
class AppMenuBadge extends StatelessWidget {
  const AppMenuBadge({required this.count, super.key});

  final String count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Label tiêu đề section (in hoa, letter spacing).
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: AppColors.textGrey,
      ),
    );
  }
}
