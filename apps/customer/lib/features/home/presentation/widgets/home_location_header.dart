import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../controllers/home_controller.dart';
import 'location_picker_sheet.dart';

class HomeLocationHeader extends GetView<HomeController> {
  const HomeLocationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accentGold, AppColors.primaryOrange],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LocationBar(),
            const SizedBox(height: 10),
            const _SearchBar(),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

void _openLocationPicker() {
  Get.bottomSheet(
    const LocationPickerSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
  );
}

class _LocationBar extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openLocationPicker,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: AppColors.textDark,
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Obx(() {
                final name = controller.locationName.value;
                final isEmpty = name.isEmpty;
                return Text(
                  isEmpty ? 'Thêm địa chỉ giao hàng...' : name,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 15,
                    color: isEmpty ? AppColors.textGrey : AppColors.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                );
              }),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _openLocationPicker,
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.textDark,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.search),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: AppColors.textGrey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tìm món ăn hoặc nhà hàng...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
