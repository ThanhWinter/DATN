import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../data/models/category_model.dart';
import '../../data/models/food_model.dart';
import '../controllers/menu_controller.dart';

class AddFoodSheet extends StatefulWidget {
  const AddFoodSheet({super.key});

  @override
  State<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<AddFoodSheet> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  CategoryModel? _selectedCategory;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final controller = Get.find<MenuController>();
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty || _selectedCategory == null) {
      Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
      return;
    }
    final price = double.tryParse(_priceCtrl.text.replaceAll('.', ''));
    if (price == null) {
      Get.snackbar('Lỗi', 'Giá không hợp lệ',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
      return;
    }
    controller.addFood(FoodModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameCtrl.text.trim(),
      price: price,
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    ));
    Get.back();
    Get.snackbar('Thành công', 'Đã thêm món ăn',
        backgroundColor: AppColors.successGreen, colorText: AppColors.white);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MenuController>();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Thêm món ăn mới', style: AppTextStyles.h3),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
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
              items: controller.categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c.name));
              }).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            )),
            const SizedBox(height: 14),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Mô tả (tuỳ chọn)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.grey400),
                    SizedBox(height: 6),
                    Text('Chọn ảnh món ăn', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(label: 'Thêm món', onPressed: _submit),
            ),
          ],
        ),
      ),
    );
  }
}
