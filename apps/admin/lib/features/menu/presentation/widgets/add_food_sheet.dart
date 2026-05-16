import 'dart:io';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/category_model.dart';
import '../controllers/menu_controller.dart';
import '../utils/picked_image_preview.dart';

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
  File? _previewImageFile;
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
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 100,
    );
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      compressQuality: 95,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cắt ảnh món ăn',
          toolbarColor: AppColors.primaryOrange,
          activeControlsWidgetColor: AppColors.primaryOrange,
          lockAspectRatio: true,
        ),
      ],
    );
    if (cropped == null) return;

    final compressed = await compressPickedImageToTempJpeg(File(cropped.path));
    if (compressed == null) return;
    if (!mounted) return;
    setState(() {
      _previewImageFile = compressed;
      _imageFilename = picked.name;
    });
  }

  Future<void> _submit() async {
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

    final desc = _descCtrl.text.trim();
    final category = _selectedCategory!;
    final imageFile = _previewImageFile;
    final imageFilename = _imageFilename;

    final imageBytes = imageFile != null ? await imageFile.readAsBytes() : null;
    if (!mounted) return;

    Get.back();
    Get.find<MenuController>().addFood(
      name,
      price,
      category.id,
      description: desc.isEmpty ? null : desc,
      imageBytes: imageBytes,
      imageFilename: imageFilename,
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
            inputFormatters: [ThousandsSeparatorInputFormatter()],
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
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
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
                  contentPadding: EdgeInsets.fromLTRB(48, 16, 12, 16),
                ),
              ),
              const Positioned(
                left: 12,
                top: 16,
                child: Icon(Icons.notes_outlined, color: AppColors.grey600),
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
                  color: _previewImageFile != null
                      ? AppColors.primaryOrange
                      : AppColors.grey300,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: _previewImageFile != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          _previewImageFile!,
                          fit: BoxFit.cover,
                          cacheWidth: 600,
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () async {
                              try {
                                await _previewImageFile?.delete();
                              } catch (_) {}
                              setState(() => _previewImageFile = null);
                            },
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
    );
  }
}
