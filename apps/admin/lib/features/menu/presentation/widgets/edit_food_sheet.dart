import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../data/models/category_model.dart';
import '../../data/models/food_model.dart';
import '../controllers/menu_controller.dart';

class EditFoodSheet extends StatefulWidget {
  const EditFoodSheet({required this.food, super.key});

  final FoodModel food;

  @override
  State<EditFoodSheet> createState() => _EditFoodSheetState();
}

class _EditFoodSheetState extends State<EditFoodSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.food.name);
    _priceCtrl =
        TextEditingController(text: widget.food.price.toInt().toString());
    _descCtrl = TextEditingController(text: widget.food.description ?? '');

    final controller = Get.find<MenuController>();
    _selectedCategory = controller.categories
        .firstWhereOrNull((c) => c.id == widget.food.categoryId);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final priceRaw = _priceCtrl.text.replaceAll('.', '').trim();
    final price = double.tryParse(priceRaw);

    if (name.isEmpty || priceRaw.isEmpty || _selectedCategory == null) {
      Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin bắt buộc (*)',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
      return;
    }
    if (price == null || price <= 0) {
      Get.snackbar('Lỗi', 'Giá không hợp lệ',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
      return;
    }

    Get.back();
    Get.find<MenuController>().updateFood(
      widget.food.id,
      name: name,
      price: price,
      categoryId: _selectedCategory!.id,
      description:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MenuController>();
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Chỉnh sửa món ăn', style: AppTextStyles.h3),
                  const Spacer(),
                  if (widget.food.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppNetworkImage(
                        url: widget.food.imageUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        memCacheWidth: 48,
                        memCacheHeight: 48,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Tên món ăn *',
                  prefixIcon: Icon(Icons.restaurant_menu_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá (VNĐ) *',
                  prefixIcon: Icon(Icons.payments_outlined),
                  suffixText: 'đ',
                ),
              ),
              const SizedBox(height: 14),
              Obx(() => DropdownButtonFormField<CategoryModel>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Danh mục *',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: controller.categories
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  )),
              const SizedBox(height: 14),
              Stack(
                children: [
                  TextField(
                    controller: _descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả (tuỳ chọn)',
                      alignLabelWithHint: true,
                      contentPadding:
                          EdgeInsets.fromLTRB(48, 16, 12, 16),
                    ),
                  ),
                  const Positioned(
                    left: 12,
                    top: 16,
                    child: Icon(Icons.notes_outlined,
                        color: AppColors.grey600),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child:
                    PrimaryButton(label: 'Lưu thay đổi', onPressed: _submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
