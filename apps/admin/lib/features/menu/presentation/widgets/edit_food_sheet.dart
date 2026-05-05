import 'dart:io';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/category_model.dart';
import '../../data/models/food_model.dart';
import '../controllers/menu_controller.dart';
import '../utils/picked_image_preview.dart';

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
  File? _newImageFile;
  String? _newImageFilename;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.food.name);
    _priceCtrl = TextEditingController(text: widget.food.price.toInt().toVnd());
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

    final compressed =
        await compressPickedImageToTempJpeg(File(cropped.path));
    if (compressed == null) return;
    setState(() {
      _newImageFile = compressed;
      _newImageFilename = picked.name;
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

    Get.back();
    Get.find<MenuController>().updateFood(
      widget.food.id,
      name: name,
      price: price,
      categoryId: _selectedCategory!.id,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      imageBytes: _newImageFile != null
          ? await _newImageFile!.readAsBytes()
          : null,
      imageFilename: _newImageFilename,
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
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
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
              const Text('Chỉnh sửa món ăn', style: AppTextStyles.h3),
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
                      color: _newImageFile != null
                          ? AppColors.primaryOrange
                          : AppColors.grey300,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _newImageFile != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _newImageFile!,
                              fit: BoxFit.cover,
                              cacheWidth: 600,
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () async {
                                  try {
                                    await _newImageFile?.delete();
                                  } catch (_) {}
                                  setState(() => _newImageFile = null);
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
                      : widget.food.imageUrl != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                AppNetworkImage(
                                  url: widget.food.imageUrl!,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: Colors.black45,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: const Text(
                                      'Nhấn để thay ảnh',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
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
                                Text('Thêm ảnh món ăn',
                                    style: AppTextStyles.bodySmall),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(label: 'Lưu thay đổi', onPressed: _submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
