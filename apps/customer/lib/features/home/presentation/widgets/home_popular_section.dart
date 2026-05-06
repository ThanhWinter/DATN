import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../data/models/home_items.dart';
import '../controllers/home_controller.dart';

class HomePopularSection extends GetView<HomeController> {
  const HomePopularSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.loadedFoodItems;
      if (items.isEmpty) return const SizedBox.shrink();

      return Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Thực đơn',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                Text(
                  '${controller.loadedFoodItems.length}/${controller.totalFoodCount.value} món',
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemCount: items.length,
              itemBuilder: (_, index) => RepaintBoundary(
                child: _FoodCard(
                  item: items[index],
                  onTap: () => controller.navigateToFoodDetail(items[index]),
                ),
              ),
            ),
            if (controller.hasMoreFoods) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: controller.loadMoreFoods,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                          color: AppColors.primaryOrange, width: 1),
                    ),
                  ),
                  child: const Text(
                    'Xem thêm',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

// ── Food Card ──────────────────────────────────────────────────────────────────

class _FoodCard extends StatelessWidget {
  final FoodItemModel item;
  final VoidCallback onTap;

  const _FoodCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: item.isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Ảnh ─────────────────────────────────────────────────────
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      item.imageUrl != null
                          ? AppNetworkImage(
                              url: item.imageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: _placeholder(),
                            )
                          : _placeholder(),
                      if (!item.isAvailable)
                        Container(
                          color: Colors.black.withValues(alpha: 0.42),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Tạm hết',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Info ──────────────────────────────────────────────────
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.price.toInt().toVnd()}đ',
                              style: const TextStyle(
                                color: AppColors.primaryOrange,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _AddButton(item: item),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFF5F5F5),
        child: const Center(
          child: Icon(Icons.fastfood_rounded,
              color: AppColors.grey400, size: 28),
        ),
      );
}

// ── Add Button ─────────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final FoodItemModel item;
  const _AddButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.isAvailable
          ? () {
              Get.find<CartController>().addItem(
                CartItemModel(
                  id: '${item.id}',
                  foodId: item.id,
                  name: item.name,
                  price: item.price,
                  quantity: 1,
                  imageUrl: item.imageUrl,
                  selectedOptions: const [],
                ),
              );
              Get.snackbar(
                'Đã thêm vào giỏ',
                item.name,
                duration: const Duration(seconds: 1),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primaryOrange,
                colorText: AppColors.white,
                margin: const EdgeInsets.all(12),
                borderRadius: 10,
              );
            }
          : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color:
              item.isAvailable ? AppColors.primaryOrange : AppColors.grey300,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
      ),
    );
  }
}
