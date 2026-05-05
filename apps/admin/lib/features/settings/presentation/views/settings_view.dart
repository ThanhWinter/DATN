import 'dart:typed_data';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/settings_models.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.grey100,
        appBar: AppBar(
          title: const Text('Cài đặt cửa hàng', style: AppTextStyles.h3),
          backgroundColor: AppColors.white,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.primaryOrange,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.primaryOrange,
            labelStyle:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'Banner quảng cáo'),
              Tab(text: 'Thông tin cửa hàng'),
            ],
          ),
        ),
        body: SnapHelperWidget(
          isLoading: controller.isLoading,
          error: controller.error,
          onSuccess: () => const TabBarView(
            children: [
              _BannersTab(),
              _StoreTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab 1: Banners ────────────────────────────────────────────────────────────

class _BannersTab extends GetView<SettingsController> {
  const _BannersTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: Obx(() {
        if (controller.isBannerEmpty.value) {
          return const AppEmptyState(
            icon: Icons.image_outlined,
            message: 'Chưa có banner quảng cáo nào',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.banners.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _BannerCard(banner: controller.banners[i]),
        );
      }),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            onPressed: controller.isUploading.value
                ? null
                : () => _showAddBannerSheet(context),
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
                : const Icon(Icons.add, color: AppColors.white),
            label: Text(
              controller.isUploading.value ? 'Đang tải...' : 'Thêm banner',
              style: const TextStyle(
                  color: AppColors.white, fontWeight: FontWeight.bold),
            ),
          )),
    );
  }

  void _showAddBannerSheet(BuildContext context) {
    Get.bottomSheet(
      const _AddBannerSheet(),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
    );
  }
}

class _BannerCard extends GetView<SettingsController> {
  const _BannerCard({required this.banner});

  final BannerModel banner;

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
            controller.deleteBanner(banner.id);
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

  void _openEdit() {
    Get.bottomSheet(
      _EditBannerSheet(banner: banner),
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = banner.isActive;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? AppColors.grey200 : AppColors.grey300,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: active ? 1.0 : 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (banner.imageUrl != null)
                  AppNetworkImage(
                    url: banner.imageUrl!,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 80,
                    color: AppColors.grey200,
                    child: const Icon(Icons.image_outlined,
                        size: 36, color: AppColors.grey400),
                  ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:
                          active ? AppColors.successGreen : AppColors.grey600,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      active ? 'Đang hiện' : 'Đã ẩn',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                  // Toggle
                  Switch(
                    value: banner.isActive,
                    onChanged: (_) => controller.toggleBannerStatus(banner),
                    activeThumbColor: AppColors.successGreen,
                    activeTrackColor:
                        AppColors.successGreen.withValues(alpha: 0.4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  // Edit
                  IconButton(
                    onPressed: _openEdit,
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
}

class _EditBannerSheet extends GetView<SettingsController> {
  const _EditBannerSheet({required this.banner});

  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    final titleCtrl = TextEditingController(text: banner.title);
    final linkCtrl = TextEditingController(text: banner.linkUrl ?? '');
    final pickedBytes = Rxn<Uint8List>();
    final pickedName = ''.obs;

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
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề banner *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: linkCtrl,
              decoration: const InputDecoration(
                labelText: 'Đường dẫn (tuỳ chọn)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => GestureDetector(
                  onTap: () async {
                    final img = await ImagePicker().pickImage(
                        source: ImageSource.gallery, imageQuality: 85);
                    if (img == null) return;
                    pickedBytes.value = await img.readAsBytes();
                    pickedName.value = img.name;
                  },
                  child: Container(
                    width: double.infinity,
                    height: pickedBytes.value != null ? 160 : 60,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey300),
                    ),
                    child: pickedBytes.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(pickedBytes.value!,
                                fit: BoxFit.cover),
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
                )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) {
                    Get.snackbar('Thiếu thông tin', 'Vui lòng nhập tiêu đề.',
                        snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  Get.back();
                  await controller.updateBanner(
                    id: banner.id,
                    title: title,
                    linkUrl: linkCtrl.text.trim().isNotEmpty
                        ? linkCtrl.text.trim()
                        : null,
                    imageBytes: pickedBytes.value,
                    filename:
                        pickedName.value.isNotEmpty ? pickedName.value : null,
                  );
                },
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

class _AddBannerSheet extends GetView<SettingsController> {
  const _AddBannerSheet();

  @override
  Widget build(BuildContext context) {
    final titleCtrl = TextEditingController();
    final linkCtrl = TextEditingController();
    final pickedBytes = Rxn<Uint8List>();
    final pickedName = ''.obs;

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

            // Tiêu đề
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề banner *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Link (optional)
            TextField(
              controller: linkCtrl,
              decoration: const InputDecoration(
                labelText: 'Đường dẫn (tuỳ chọn)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Chọn ảnh
            Obx(() => GestureDetector(
                  onTap: () async {
                    final img = await ImagePicker().pickImage(
                        source: ImageSource.gallery, imageQuality: 85);
                    if (img == null) return;
                    pickedBytes.value = await img.readAsBytes();
                    pickedName.value = img.name;
                  },
                  child: Container(
                    width: double.infinity,
                    height: pickedBytes.value != null ? 160 : 80,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey300),
                    ),
                    child: pickedBytes.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(pickedBytes.value!,
                                fit: BoxFit.cover),
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
                )),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final bytes = pickedBytes.value;
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty || bytes == null) {
                    Get.snackbar(
                        'Thiếu thông tin', 'Vui lòng nhập tiêu đề và chọn ảnh.',
                        snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  Get.back();
                  await controller.addBanner(
                    title: title,
                    bytes: bytes,
                    filename: pickedName.value.isNotEmpty
                        ? pickedName.value
                        : 'banner.jpg',
                    linkUrl: linkCtrl.text.trim().isNotEmpty
                        ? linkCtrl.text.trim()
                        : null,
                  );
                },
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

// ── Tab 2: Store Setting ──────────────────────────────────────────────────────

class _StoreTab extends GetView<SettingsController> {
  const _StoreTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Trạng thái cửa hàng ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trạng thái cửa hàng', style: AppTextStyles.h3),
                      SizedBox(height: 4),
                      Text('Bật/tắt nhận đơn hàng mới',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Obx(() => Switch(
                      value: controller.isOpen.value,
                      onChanged: (v) => controller.isOpen.value = v,
                      activeThumbColor: AppColors.successGreen,
                      activeTrackColor:
                          AppColors.successGreen.withValues(alpha: 0.4),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Form thông tin ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _FormField(
                  label: 'Tên cửa hàng',
                  ctrl: controller.storeNameCtrl,
                ),
                const SizedBox(height: 12),
                _FormField(
                  label: 'Hotline',
                  ctrl: controller.hotlineCtrl,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _FormField(
                  label: 'Phí giao cơ bản (₫)',
                  ctrl: controller.shippingFeeCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _FormField(
                  label: 'Miễn phí ship từ (₫)',
                  ctrl: controller.freeShipCtrl,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.saveStoreSetting,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    disabledBackgroundColor: AppColors.grey300,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: AppColors.white),
                        )
                      : const Text('Lưu cài đặt',
                          style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                ),
              )),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.ctrl,
    this.keyboardType,
  });

  final String label;
  final TextEditingController ctrl;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      style: AppTextStyles.bodyMedium,
    );
  }
}
