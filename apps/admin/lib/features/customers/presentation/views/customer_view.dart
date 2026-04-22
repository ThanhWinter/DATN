import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/customer_model.dart';
import '../controllers/customer_controller.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Khách hàng', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: controller.search,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, email, số điện thoại...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.grey100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: SnapHelperWidget(
              isLoading: controller.isLoading,
              error: controller.error,
              onSuccess: () => Obx(() {
                final list = controller.filteredCustomers;
                if (list.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.people_outline,
                    message: 'Không tìm thấy khách hàng',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _CustomerCard(customer: list[i]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends GetView<CustomerController> {
  const _CustomerCard({required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.15),
              child: Text(
                customer.initials,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primaryOrange,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.fullName, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 2),
                  Text(customer.email, style: AppTextStyles.bodySmall),
                  Text(customer.phone, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Stat(
                        icon: Icons.receipt_outlined,
                        label: '${customer.totalOrders} đơn',
                      ),
                      const SizedBox(width: 12),
                      _Stat(
                        icon: Icons.payments_outlined,
                        label: '${customer.totalSpent.toInt().toVnd()}đ',
                        color: AppColors.primaryOrange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.grey600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (v) {
                if (v == 'delete') _confirmDelete(context);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(children: [
                    Icon(Icons.visibility_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Xem chi tiết'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Xoá', style: TextStyle(color: Colors.red)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá khách hàng'),
        content: Text('Bạn muốn xoá "${customer.fullName}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Huỷ')),
          TextButton(
            onPressed: () {
              controller.deleteCustomer(customer.id);
              Get.back();
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color ?? AppColors.grey600),
        const SizedBox(width: 3),
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color ?? AppColors.textGrey,
            )),
      ],
    );
  }
}
