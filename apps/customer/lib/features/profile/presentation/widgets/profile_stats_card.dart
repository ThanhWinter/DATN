import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class ProfileStatsCard extends StatelessWidget {
  final int totalOrders;
  final double totalSaved;

  const ProfileStatsCard({
    super.key,
    required this.totalOrders,
    required this.totalSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
      child: Row(
        children: [
          _StatItem(
            icon: Icons.receipt_long_outlined,
            value: '$totalOrders',
            label: 'Đơn hàng',
          ),
          Container(width: 1, height: 48, color: AppColors.grey300),
          _StatItem(
            icon: Icons.local_offer_outlined,
            value: '${totalSaved.toVnd()} ₫',
            label: 'Tiết kiệm được',
            iconColor: AppColors.successGreen,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor = AppColors.primaryOrange,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
