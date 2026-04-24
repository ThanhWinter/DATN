import 'dart:typed_data';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/category_model.dart';
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
  Uint8List? _imageBytes;
  String? _imageFilename;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<MenuController>();
    final currentId = controller.selectedCategoryId.value;
    if (currentId != null) {
      _selectedCategory =
          controller.categories.firstWhereOrNull((c) => c.id == currentId);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageFilename = file.name;
    });
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
    Get.find<MenuController>().addFood(
      name,
      price,
      _selectedCategory!.id,
      description:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      imageBytes: _imageBytes != null ? List<int>.from(_imageBytes!) : null,
      imageFilename: _imageFilename,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final controller = Get.find<MenuController>();
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + keyboardHeight),
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
          const Text('Thêm món ăn mới', style: AppTextStyles.h3),
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
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _imageBytes != null
                      ? AppColors.primaryOrange
                      : AppColors.grey300,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: _imageBytes != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(_imageBytes!, fit: BoxFit.cover),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _imageBytes = null),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 32, color: AppColors.grey400),
                        SizedBox(height: 6),
                        Text('Chọn ảnh món ăn',
                            style: AppTextStyles.bodySmall),
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
    );
  }
}
