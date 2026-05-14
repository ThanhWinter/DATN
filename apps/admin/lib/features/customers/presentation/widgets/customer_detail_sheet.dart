import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/customer_model.dart';
import '../controllers/customer_controller.dart';

class CustomerDetailSheet extends StatelessWidget {
  const CustomerDetailSheet({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Avatar + tên
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.15),
            child: Text(
              customer.initials,
              style: AppTextStyles.h3.copyWith(color: AppColors.primaryOrange),
            ),
          ),
          const SizedBox(height: 12),
          Text(customer.fullName, style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(customer.email,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
          const SizedBox(height: 20),
          // Thống kê nhanh
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _StatTile(
                  icon: Icons.receipt_outlined,
                  label: 'Tổng đơn',
                  value: '${customer.totalOrders}',
                ),
                const SizedBox(width: 12),
                _StatTile(
                  icon: Icons.payments_outlined,
                  label: 'Đã chi',
                  value: '${customer.totalSpent.toInt().toVnd()}đ',
                  valueColor: AppColors.primaryOrange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          // Thông tin chi tiết
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Điện thoại',
            value: customer.phone.isEmpty ? '—' : customer.phone,
          ),
          _InfoRow(
            icon: Icons.wc_outlined,
            label: 'Giới tính',
            value: customer.gender == 1
                ? 'Nam'
                : customer.gender == 2
                    ? 'Nữ'
                    : 'Không xác định',
          ),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Ngày tham gia',
            value:
                '${customer.createdAt.day.toString().padLeft(2, '0')}/${customer.createdAt.month.toString().padLeft(2, '0')}/${customer.createdAt.year}',
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Chỉ hiển thị nút khoá/mở khoá cho CUSTOMER, không cho ADMIN
                if (!customer.isAdmin) ...[
                  Expanded(
                    child: customer.isLocked
                        ? OutlinedButton.icon(
                            onPressed: () {
                              Get.back();
                              Get.find<CustomerController>()
                                  .unlockCustomer(customer.id);
                            },
                            icon: const Icon(Icons.lock_open_outlined,
                                size: 18, color: Colors.green),
                            label: const Text('Mở khoá',
                                style: TextStyle(color: Colors.green)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.green),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          )
                        : OutlinedButton.icon(
                            onPressed: () {
                              Get.back();
                              Get.find<CustomerController>()
                                  .lockCustomer(customer.id);
                            },
                            icon: const Icon(Icons.lock_outline,
                                size: 18, color: AppColors.errorRed),
                            label: const Text('Khoá tài khoản',
                                style: TextStyle(color: AppColors.errorRed)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.errorRed),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: Get.back,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: valueColor ?? AppColors.grey600),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                color: valueColor ?? AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.grey600),
          const SizedBox(width: 12),
          Text(label,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
          const Spacer(),
          Text(value, style: AppTextStyles.labelLarge),
        ],
      ),
    );
  }
}
