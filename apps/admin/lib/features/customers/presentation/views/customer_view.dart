import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/customer_model.dart';
import '../controllers/customer_controller.dart';
import '../widgets/customer_detail_sheet.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.grey100,
        appBar: AppBar(
          title: const Text('Người dùng', style: AppTextStyles.h3),
          backgroundColor: AppColors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Khách hàng'),
              Tab(text: 'Admin'),
            ],
            labelColor: AppColors.primaryOrange,
            indicatorColor: AppColors.primaryOrange,
            unselectedLabelColor: AppColors.grey600,
            dividerColor: AppColors.grey200,
          ),
        ),
        body: TabBarView(
          children: [
            _UserListTab(
              isLoading: controller.isLoadingCustomers,
              error: controller.errorCustomers,
              filteredList: controller.filteredCustomers,
              onRefresh: controller.loadCustomers,
              onSearch: controller.searchCustomers,
              hintText: 'Tìm theo tên, email, số điện thoại...',
              emptyMessage: 'Không tìm thấy khách hàng',
              canLock: true,
            ),
            _UserListTab(
              isLoading: controller.isLoadingAdmins,
              error: controller.errorAdmins,
              filteredList: controller.filteredAdmins,
              onRefresh: controller.loadAdmins,
              onSearch: controller.searchAdmins,
              hintText: 'Tìm theo tên, email, số điện thoại...',
              emptyMessage: 'Không tìm thấy admin',
              canLock: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserListTab extends GetView<CustomerController> {
  const _UserListTab({
    required this.isLoading,
    required this.error,
    required this.filteredList,
    required this.onRefresh,
    required this.onSearch,
    required this.hintText,
    required this.emptyMessage,
    required this.canLock,
  });

  final RxBool isLoading;
  final Rxn<String> error;
  final RxList<CustomerModel> filteredList;
  final Future<void> Function() onRefresh;
  final void Function(String) onSearch;
  final String hintText;
  final String emptyMessage;
  final bool canLock;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: TextField(
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: hintText,
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
            isLoading: isLoading,
            error: error,
            onRefresh: onRefresh,
            onSuccess: () => RefreshIndicator(
              onRefresh: onRefresh,
              color: AppColors.primaryOrange,
              child: Obx(() {
                final list = filteredList;
                if (list.isEmpty) {
                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        child: AppEmptyState(
                          icon: Icons.people_outline,
                          message: emptyMessage,
                        ),
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) =>
                      _UserCard(user: list[i], canLock: canLock),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _UserCard extends GetView<CustomerController> {
  const _UserCard({required this.user, required this.canLock});

  final CustomerModel user;
  final bool canLock;

  void _showDetail() {
    Get.bottomSheet(
      CustomerDetailSheet(customer: user),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  void _confirmLock(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Khoá tài khoản'),
        content: Text(
            'Bạn muốn khoá tài khoản "${user.fullName}"?\nNgười dùng sẽ không thể đăng nhập cho đến khi được mở khoá.'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Huỷ')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.lockCustomer(user.id);
            },
            child: const Text('Khoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locked = user.isLocked;
    return Opacity(
      opacity: locked ? 0.55 : 1.0,
      child: Card(
        elevation: 0,
        color: locked ? AppColors.grey100 : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: locked
                        ? AppColors.grey300
                        : AppColors.primaryOrange.withValues(alpha: 0.15),
                    child: Text(
                      user.initials,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: locked
                            ? AppColors.grey600
                            : AppColors.primaryOrange,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (locked)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.errorRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock,
                            size: 10, color: AppColors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                            child: Text(user.fullName,
                                style: AppTextStyles.labelLarge)),
                        if (locked) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Đã khoá',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.errorRed,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(user.email, style: AppTextStyles.bodySmall),
                    Text(user.phone, style: AppTextStyles.bodySmall),
                    if (!user.isAdmin) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _Stat(
                            icon: Icons.receipt_outlined,
                            label: '${user.totalOrders} đơn',
                          ),
                          const SizedBox(width: 12),
                          _Stat(
                            icon: Icons.payments_outlined,
                            label: '${user.totalSpent.toInt().toVnd()}đ',
                            color: locked ? null : AppColors.primaryOrange,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.grey600),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (v) {
                  if (v == 'view') _showDetail();
                  if (v == 'lock') _confirmLock(context);
                  if (v == 'unlock') controller.unlockCustomer(user.id);
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
                  if (canLock && !locked)
                    const PopupMenuItem(
                      value: 'lock',
                      child: Row(children: [
                        Icon(Icons.lock_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Khoá tài khoản',
                            style: TextStyle(color: Colors.red)),
                      ]),
                    ),
                  if (canLock && locked)
                    const PopupMenuItem(
                      value: 'unlock',
                      child: Row(children: [
                        Icon(Icons.lock_open_outlined,
                            size: 18, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Mở khoá tài khoản',
                            style: TextStyle(color: Colors.green)),
                      ]),
                    ),
                ],
              ),
            ],
          ),
        ),
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
        Text(
          label,
          style: AppTextStyles.bodySmall
              .copyWith(color: color ?? AppColors.textGrey),
        ),
      ],
    );
  }
}
