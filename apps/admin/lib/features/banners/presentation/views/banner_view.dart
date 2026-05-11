import 'dart:typed_data';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../settings/data/models/settings_models.dart';
import '../controllers/optimized_banner_controller.dart';

class BannerView extends GetView<OptimizedBannerController> {
  const BannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Banner quảng cáo', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onRefresh: controller.loadData,
        onSuccess: () => _BannerList(controller: controller),
      ),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            onPressed: controller.isUploading.value
                ? null
                : () => _openAddSheet(context),
            backgroundColor: controller.isUploading.value
                ? AppColors.grey300
                : AppColors.primaryOrange,
            icon: controller.isUploading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white),
                  )
                : const Icon(Icons.add_rounded, color: AppColors.white),
            label: Text(
              controller.isUploading.value ? 'Đang tải...' : 'Thêm banner',
              style: const TextStyle(
                  color: AppColors.white, fontWeight: FontWeight.w700),
            ),
          )),
    );
  }

  void _openAddSheet(BuildContext context) {
    Get.bottomSheet(
      const _AddBannerSheet(),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
    );
  }
}

// ── Banner List ───────────────────────────────────────────────────────────────

class _BannerList extends StatelessWidget {
  const _BannerList({required this.controller});
  final OptimizedBannerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final banners = controller.banners;
      if (banners.isEmpty) {
        return const AppEmptyState(
          icon: Icons.image_outlined,
          message: 'Chưa có banner nào.\nNhấn "+ Thêm banner" để tạo mới.',
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadData,
        color: AppColors.primaryOrange,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: banners.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _BannerCard(banner: banners[i]),
        ),
      );
    });
  }
}

// ── Banner Card ───────────────────────────────────────────────────────────────

class _BannerCard extends GetView<OptimizedBannerController> {
  const _BannerCard({required this.banner});
  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: banner.isActive ? 1.0 : 0.55,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image preview ───────────────────────────────────────────
            AppBannerCard(
              imageUrl: banner.imageUrl,
              height: 150,
              borderRadius: 0,
              fallbackWidget: Container(
                color: AppColors.grey200,
                child: const Icon(Icons.image_outlined,
                    size: 36, color: AppColors.grey400),
              ),
              overlayChild: Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: banner.isActive
                        ? AppColors.successGreen
                        : AppColors.grey600,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    banner.isActive ? 'Đang hiện' : 'Đã ẩn',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            // ── Info + actions ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(banner.title, style: AppTextStyles.bodyLarge),
                        if (banner.linkUrl != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            banner.linkUrl!,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.primaryOrange),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Toggle active
                  Switch(
                    value: banner.isActive,
                    onChanged: (_) => controller.toggleStatus(banner),
                    activeThumbColor: AppColors.successGreen,
                    activeTrackColor:
                        AppColors.successGreen.withValues(alpha: 0.4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  // Edit
                  IconButton(
                    onPressed: () => _openEdit(),
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.primaryOrange, size: 20),
                    tooltip: 'Sửa',
                  ),
                  // Delete
                  IconButton(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.errorRed, size: 20),
                    tooltip: 'Xoá',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEdit() {
    Get.bottomSheet(
      _EditBannerSheet(banner: banner),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
    );
  }

  void _confirmDelete() {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Xoá banner', style: AppTextStyles.h3),
      content: Text('Bạn chắc chắn muốn xoá banner "${banner.title}"?'),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text('Huỷ', style: TextStyle(color: AppColors.textGrey)),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            controller.deleteBanner(banner);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.errorRed,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Xoá ngay'),
        ),
      ],
    ));
  }
}

// ── Add Banner Sheet — StatefulWidget giữ state khi bàn phím xuất hiện ────────

class _AddBannerSheet extends StatefulWidget {
  const _AddBannerSheet();

  @override
  State<_AddBannerSheet> createState() => _AddBannerSheetState();
}

class _AddBannerSheetState extends State<_AddBannerSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _linkCtrl;
  Uint8List? _pickedBytes;
  String _pickedName = '';

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _linkCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img == null) return;
    final bytes = await img.readAsBytes();
    setState(() {
      _pickedBytes = bytes;
      _pickedName = img.name;
    });
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _pickedBytes == null) {
      Get.snackbar('Thiếu thông tin', 'Vui lòng nhập tiêu đề và chọn ảnh.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.back();
    await Get.find<OptimizedBannerController>().addBanner(
      title: title,
      bytes: _pickedBytes!,
      filename: _pickedName.isNotEmpty ? _pickedName : 'banner.jpg',
      linkUrl: _linkCtrl.text.trim().isNotEmpty ? _linkCtrl.text.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Thêm banner mới', style: AppTextStyles.h3),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề banner *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _linkCtrl,
              decoration: const InputDecoration(
                labelText: 'Đường dẫn (tuỳ chọn)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: _pickedBytes != null ? 160 : 80,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: _pickedBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_pickedBytes!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 32, color: AppColors.grey400),
                          SizedBox(height: 6),
                          Text('Chọn ảnh banner',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Thêm banner',
                    style: TextStyle(
                        color: AppColors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Edit Banner Sheet — StatefulWidget giữ state khi bàn phím xuất hiện ───────

class _EditBannerSheet extends StatefulWidget {
  const _EditBannerSheet({required this.banner});
  final BannerModel banner;

  @override
  State<_EditBannerSheet> createState() => _EditBannerSheetState();
}

class _EditBannerSheetState extends State<_EditBannerSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _linkCtrl;
  Uint8List? _pickedBytes;
  String _pickedName = '';

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.banner.title);
    _linkCtrl = TextEditingController(text: widget.banner.linkUrl ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (img == null) return;
    final bytes = await img.readAsBytes();
    setState(() {
      _pickedBytes = bytes;
      _pickedName = img.name;
    });
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      Get.snackbar('Thiếu thông tin', 'Vui lòng nhập tiêu đề.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.back();
    await Get.find<OptimizedBannerController>().updateBanner(
      id: widget.banner.id,
      title: title,
      linkUrl: _linkCtrl.text.trim().isNotEmpty ? _linkCtrl.text.trim() : null,
      imageBytes: _pickedBytes,
      filename: _pickedName.isNotEmpty ? _pickedName : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sửa banner', style: AppTextStyles.h3),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề banner *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _linkCtrl,
              decoration: const InputDecoration(
                labelText: 'Đường dẫn (tuỳ chọn)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: _pickedBytes != null ? 160 : 60,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: _pickedBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_pickedBytes!, fit: BoxFit.cover),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image_outlined,
                              size: 20, color: AppColors.grey400),
                          const SizedBox(width: 8),
                          Text(
                            'Đổi ảnh (tuỳ chọn)',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textGrey),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lưu thay đổi',
                    style: TextStyle(
                        color: AppColors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
