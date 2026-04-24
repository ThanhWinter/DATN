import 'dart:typed_data';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/menu_controller.dart';

class AddCategorySheet extends StatefulWidget {
  const AddCategorySheet({super.key});

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageFilename;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
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
    if (name.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập tên danh mục',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
      return;
    }
    Get.back();
    Get.find<MenuController>().addCategory(
      name,
      description:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      imageBytes: _imageBytes != null ? List<int>.from(_imageBytes!) : null,
      imageFilename: _imageFilename,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
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
          const Text('Thêm danh mục mới', style: AppTextStyles.h3),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.sentences,
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
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 100,
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
                                  size: 14, color: Colors.white),
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
                        Text('Chọn ảnh danh mục',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(label: 'Thêm danh mục', onPressed: _submit),
          ),
        ],
      ),
    );
  }
}
