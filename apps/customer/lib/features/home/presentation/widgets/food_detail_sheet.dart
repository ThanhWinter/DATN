import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/home_items.dart';
import '../controllers/food_detail_controller.dart';

class FoodDetailSheet extends GetView<FoodDetailController> {
  const FoodDetailSheet({super.key});

  static void show(FoodItemModel item) {
    Get.put(FoodDetailController(item: item));
    Get.bottomSheet(
      const FoodDetailSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildName(),
                        if (controller.item.description != null &&
                            controller.item.description!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDescription(),
                        ],
                        const SizedBox(height: 20),
                        _buildDivider(),
                        const SizedBox(height: 16),
                        _buildQuantityRow(),
                        const SizedBox(height: 16),
                        _buildDivider(),
                        const SizedBox(height: 16),
                        _buildNoteField(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildAddToCartBar(),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.grey300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return AppNetworkImage(
      url: controller.item.imageUrl,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
    );
  }

  Widget _buildName() {
    return Text(
      controller.item.name,
      style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w800),
    );
  }

  Widget _buildDescription() {
    return Text(
      controller.item.description!,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textGrey,
        height: 1.5,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppColors.grey200);
  }

  Widget _buildQuantityRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Số lượng',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        Obx(() => Row(
              children: [
                _buildQtyButton(
                  icon: Icons.remove_rounded,
                  onTap: controller.decrease,
                  enabled: controller.quantity.value > 1,
                ),
                GestureDetector(
                  onTap: controller.showQuantityDialog,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${controller.quantity.value}',
                      style:
                          AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                _buildQtyButton(
                  icon: Icons.add_rounded,
                  onTap: controller.increase,
                  enabled: true,
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryOrange : AppColors.grey200,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.white : AppColors.grey400,
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ghi chú',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller.noteController,
          maxLines: 2,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Ví dụ: ít cay, không hành, thêm tương...',
            hintStyle:
                AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
            filled: true,
            fillColor: AppColors.grey100,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: AppColors.primaryOrange, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(
        () => GestureDetector(
          onTap: controller.addToCart,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primaryOrangeDark,
                  AppColors.primaryOrangeLight
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined,
                    color: AppColors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Thêm vào giỏ  •  ${_formatPrice(controller.totalPrice)}',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '$bufđ';
  }
}
