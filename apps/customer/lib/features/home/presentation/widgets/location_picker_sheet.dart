import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  late final HomeController _controller;
  late final TextEditingController _textController;
  late final Worker _addressWorker;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HomeController>();
    _textController = TextEditingController(text: _controller.pickerAddress.value);

    // Khi GPS lấy được địa chỉ mới → cập nhật text field tự động
    _addressWorker = ever(_controller.pickerAddress, (String address) {
      if (_textController.text != address) {
        _textController.text = address;
        _textController.selection = TextSelection.collapsed(
          offset: address.length,
        );
      }
    });

    // Tự động hỏi quyền & lấy GPS ngay khi sheet mở
    _controller.initPickerLocation();
  }

  @override
  void dispose() {
    _addressWorker.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      // Đẩy nội dung lên khi bàn phím mở
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ─────────────────────────────────────────────────────
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // ── Tiêu đề ────────────────────────────────────────────────────
            const Text('Địa chỉ giao hàng', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            const Text(
              'Nhập địa chỉ hoặc lấy vị trí hiện tại của bạn',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),

            // ── Text field địa chỉ (có thể sửa) ───────────────────────────
            TextField(
              controller: _textController,
              onChanged: _controller.updatePickerAddress,
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              minLines: 1,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Nhập địa chỉ giao hàng...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
                prefixIcon: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primaryOrange,
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.textGrey),
                  onPressed: () {
                    _textController.clear();
                    _controller.updatePickerAddress('');
                  },
                ),
                filled: true,
                fillColor: AppColors.grey100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryOrange,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Nút lấy GPS (retry nếu cần) ────────────────────────────────
            Obx(() {
              final locating = _controller.isLocating.value;
              return OutlinedButton.icon(
                onPressed: locating ? null : _controller.fetchCurrentLocation,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryOrange,
                  side: const BorderSide(color: AppColors.primaryOrange),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: locating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryOrange,
                        ),
                      )
                    : const Icon(Icons.my_location_rounded, size: 18),
                label: Text(
                  locating ? 'Đang lấy vị trí...' : 'Dùng vị trí hiện tại',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primaryOrange,
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),

            // ── Xác nhận ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _controller.confirmPickerLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Xác nhận', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
