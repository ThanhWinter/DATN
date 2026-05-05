import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../data/models/option_group_model.dart';
import '../controllers/menu_controller.dart';

class _ItemEntry {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  _ItemEntry({String name = '', double price = 0}) {
    nameCtrl.text = name;
    priceCtrl.text = price == 0 ? '0' : price.toStringAsFixed(0);
  }

  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
  }
}

class AddEditOptionGroupSheet extends StatefulWidget {
  const AddEditOptionGroupSheet({
    required this.foodId,
    this.existing,
    super.key,
  });

  final int foodId;
  final OptionGroupModel? existing;

  @override
  State<AddEditOptionGroupSheet> createState() =>
      _AddEditOptionGroupSheetState();
}

class _AddEditOptionGroupSheetState extends State<AddEditOptionGroupSheet> {
  late final MenuController _ctrl;
  late final TextEditingController _nameCtrl;
  late final List<_ItemEntry> _items;
  bool _isRequired = false;
  int _maxSelect = 1;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<MenuController>();
    final g = widget.existing;
    _nameCtrl = TextEditingController(text: g?.name ?? '');
    _isRequired = g?.isRequired ?? false;
    _maxSelect = g?.maxSelect ?? 1;
    _items = g != null && g.items.isNotEmpty
        ? g.items
            .map((i) => _ItemEntry(name: i.name, price: i.priceAdjustment))
            .toList()
        : [_ItemEntry()];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    for (final e in _items) {
      e.dispose();
    }
    super.dispose();
  }

  void _addItem() => setState(() => _items.add(_ItemEntry()));

  void _removeItem(int index) {
    if (_items.length <= 1) return;
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Thiếu thông tin', 'Vui lòng nhập tên nhóm tuỳ chọn.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final validItems = _items
        .where((e) => e.nameCtrl.text.trim().isNotEmpty)
        .toList();
    if (validItems.isEmpty) {
      Get.snackbar('Thiếu thông tin', 'Vui lòng thêm ít nhất 1 lựa chọn.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final itemsPayload = validItems.map((e) {
      final priceText = e.priceCtrl.text.trim();
      return {
        'name': e.nameCtrl.text.trim(),
        'priceAdjustment': double.tryParse(priceText) ?? 0.0,
      };
    }).toList();

    Get.back();

    if (widget.existing == null) {
      await _ctrl.createOptionGroup(
        foodId: widget.foodId,
        name: name,
        minSelect: _isRequired ? 1 : 0,
        maxSelect: _maxSelect,
        items: itemsPayload,
      );
    } else {
      await _ctrl.updateOptionGroup(
        groupId: widget.existing!.id,
        foodId: widget.foodId,
        name: name,
        minSelect: _isRequired ? 1 : 0,
        maxSelect: _maxSelect,
        items: itemsPayload,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag handle
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
              const SizedBox(height: 16),
              Text(
                isEdit ? 'Chỉnh sửa nhóm tuỳ chọn' : 'Thêm nhóm tuỳ chọn',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 20),

              // ── Tên nhóm ──────────────────────────────────────────────────
              _buildTextField(
                controller: _nameCtrl,
                label: 'Tên nhóm *',
                hint: 'VD: Lượng đường, Lượng đá, Topping...',
                icon: Icons.label_outline,
              ),
              const SizedBox(height: 16),

              // ── Bắt buộc chọn ─────────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_outlined,
                        size: 20, color: AppColors.primaryOrange),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bắt buộc phải chọn',
                              style: AppTextStyles.bodyLarge),
                          Text('Khách hàng phải chọn ít nhất 1 tuỳ chọn',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textGrey)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isRequired,
                      onChanged: (v) => setState(() => _isRequired = v),
                      activeThumbColor: AppColors.primaryOrange,
                      activeTrackColor:
                          AppColors.primaryOrange.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Chọn tối đa ───────────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.format_list_numbered_outlined,
                        size: 20, color: AppColors.primaryOrange),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Số lựa chọn tối đa',
                              style: AppTextStyles.bodyLarge),
                          Text('1 = chọn 1 (radio), >1 = chọn nhiều',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textGrey)),
                        ],
                      ),
                    ),
                    _Stepper(
                      value: _maxSelect,
                      min: 1,
                      max: 10,
                      onChanged: (v) => setState(() => _maxSelect = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Danh sách lựa chọn ────────────────────────────────────────
              Row(
                children: [
                  const Text('Danh sách lựa chọn', style: AppTextStyles.h3),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add_circle_outline,
                        size: 18, color: AppColors.primaryOrange),
                    label: const Text('Thêm',
                        style: TextStyle(color: AppColors.primaryOrange)),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildTextField(
                          controller: item.nameCtrl,
                          label: 'Tên lựa chọn',
                          hint: 'VD: Ít đường',
                          icon: Icons.circle_outlined,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: _buildTextField(
                          controller: item.priceCtrl,
                          label: '+Giá (đ)',
                          hint: '0',
                          icon: Icons.attach_money_outlined,
                          compact: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.remove_circle_outline,
                              size: 20, color: AppColors.errorRed),
                          onPressed: _items.length > 1
                              ? () => _removeItem(i)
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // ── Save ──────────────────────────────────────────────────────
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _ctrl.isMutating.value ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _ctrl.isMutating.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.white),
                            )
                          : Text(isEdit ? 'Cập nhật' : 'Lưu nhóm tuỳ chọn'),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool compact = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      style: AppTextStyles.bodyLarge,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: compact ? null : hint,
        prefixIcon: Icon(icon, size: 18, color: AppColors.primaryOrange),
        isDense: compact,
        contentPadding: compact
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 12)
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.primaryOrange, width: 1.5),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(
          icon: Icons.remove,
          enabled: value > min,
          onTap: () => onChanged(value - 1),
        ),
        Container(
          width: 36,
          alignment: Alignment.center,
          child: Text('$value',
              style: AppTextStyles.labelLarge.copyWith(fontSize: 16)),
        ),
        _StepBtn(
          icon: Icons.add,
          enabled: value < max,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn(
      {required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryOrange : AppColors.grey200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon,
            size: 16,
            color: enabled ? AppColors.white : AppColors.grey400),
      ),
    );
  }
}
