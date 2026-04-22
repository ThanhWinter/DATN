import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../data/models/category_model.dart';
import '../controllers/menu_controller.dart';

class AddCategorySheet extends StatefulWidget {
  const AddCategorySheet({super.key});

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập tên danh mục',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
      return;
    }
    Get.find<MenuController>().addCategory(CategoryModel(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    ));
    Get.back();
    Get.snackbar('Thành công', 'Đã thêm danh mục',
        backgroundColor: AppColors.successGreen, colorText: AppColors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
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
            const Text('Thêm danh mục mới', style: AppTextStyles.h3),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên danh mục *',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Mô tả (tuỳ chọn)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(label: 'Thêm danh mục', onPressed: _submit),
            ),
          ],
        ),
      ),
    );
  }
}
