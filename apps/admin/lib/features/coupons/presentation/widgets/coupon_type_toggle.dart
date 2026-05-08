import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../data/models/coupon_model.dart';

class CouponTypeToggle extends StatelessWidget {
  const CouponTypeToggle({
    required this.selectedType,
    required this.onChanged,
    super.key,
  });

  final String selectedType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            label: 'Theo %',
            icon: Icons.percent,
            selected: selectedType == CouponModel.typePercent,
            onTap: () => onChanged(CouponModel.typePercent),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TypeButton(
            label: 'Số tiền cố định',
            icon: Icons.attach_money,
            selected: selectedType == CouponModel.typeFixed,
            onTap: () => onChanged(CouponModel.typeFixed),
          ),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryOrange.withValues(alpha: 0.1)
              : AppColors.grey100,
          border: Border.all(
            color: selected ? AppColors.primaryOrange : AppColors.grey300,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primaryOrange : AppColors.grey600,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? AppColors.primaryOrange : AppColors.textGrey,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
