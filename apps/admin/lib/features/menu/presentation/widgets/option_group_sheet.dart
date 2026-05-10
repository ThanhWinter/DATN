import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../data/models/food_model.dart';
import '../../data/models/option_group_model.dart';
import '../controllers/menu_controller.dart';
import 'add_edit_option_group_sheet.dart';

class OptionGroupSheet extends StatefulWidget {
  const OptionGroupSheet({required this.food, super.key});

  final FoodModel food;

  @override
  State<OptionGroupSheet> createState() => _OptionGroupSheetState();
}

class _OptionGroupSheetState extends State<OptionGroupSheet> {
  late final MenuController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<MenuController>();
    _ctrl.loadOptionGroups(widget.food.id);
  }

  void _openAddSheet() => Get.bottomSheet(
        AddEditOptionGroupSheet(foodId: widget.food.id),
        isScrollControlled: true,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      );

  void _openEditSheet(OptionGroupModel group) => Get.bottomSheet(
        AddEditOptionGroupSheet(foodId: widget.food.id, existing: group),
        isScrollControlled: true,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      );

  void _confirmDelete(OptionGroupModel group) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xoá nhóm tuỳ chọn', style: AppTextStyles.h3),
        content: Text(
          'Xoá nhóm "${group.name}"? Tất cả lựa chọn bên trong cũng bị xoá.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Huỷ',
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _ctrl.deleteOptionGroup(group.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xoá ngay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.tune_rounded,
                        color: AppColors.primaryOrange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Quản lý tuỳ chọn',
                              style: AppTextStyles.h3),
                          Text(
                            widget.food.name,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textGrey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _openAddSheet,
                      icon: const Icon(Icons.add_circle_outline,
                          size: 18, color: AppColors.primaryOrange),
                      label: const Text('Thêm nhóm',
                          style: TextStyle(color: AppColors.primaryOrange)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 16),

          // ── Body ────────────────────────────────────────────────────────
          Flexible(
            child: SnapHelperWidget(
              isLoading: _ctrl.isOptionLoading,
              error: _ctrl.optionError,
              onRetry: () => _ctrl.loadOptionGroups(widget.food.id),
              onSuccess: () => Obx(() {
                if (_ctrl.optionGroups.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: AppEmptyState(
                      icon: Icons.tune_outlined,
                      message: 'Chưa có nhóm tuỳ chọn nào',
                      subMessage:
                          'Nhấn "Thêm nhóm" để thêm lượng đường, đá, topping...',
                    ),
                  );
                }
                return ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: _ctrl.optionGroups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final group = _ctrl.optionGroups[i];
                    return _OptionGroupCard(
                      group: group,
                      onEdit: () => _openEditSheet(group),
                      onDelete: () => _confirmDelete(group),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Option group card ─────────────────────────────────────────────────────────

class _OptionGroupCard extends StatelessWidget {
  const _OptionGroupCard({
    required this.group,
    required this.onEdit,
    required this.onDelete,
  });

  final OptionGroupModel group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name,
                          style:
                              AppTextStyles.labelLarge.copyWith(fontSize: 14)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _Badge(
                            label: group.isRequired
                                ? 'Bắt buộc'
                                : 'Không bắt buộc',
                            color: group.isRequired
                                ? AppColors.errorRed
                                : AppColors.textGrey,
                          ),
                          const SizedBox(width: 6),
                          _Badge(
                            label: group.maxSelect == 1
                                ? 'Chọn 1'
                                : 'Chọn tối đa ${group.maxSelect}',
                            color: AppColors.primaryOrange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.edit_outlined,
                        size: 17, color: AppColors.primaryOrange),
                    onPressed: onEdit,
                    tooltip: 'Chỉnh sửa',
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.delete_outline,
                        size: 17, color: AppColors.errorRed),
                    onPressed: onDelete,
                    tooltip: 'Xoá nhóm',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // items
          ...group.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item.name, style: AppTextStyles.bodyMedium),
                  ),
                  Text(
                    item.priceAdjustment == 0
                        ? 'Miễn phí'
                        : '+${item.priceAdjustment.toInt().toVnd()}đ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: item.priceAdjustment == 0
                          ? AppColors.textGrey
                          : AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall
            .copyWith(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
