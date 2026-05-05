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
      if (controller.loadedFoodItems.isEmpty) return const SizedBox.shrink();

      return Container(
        color: AppColors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.primaryOrange,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text('Thực đơn', style: AppTextStyles.h3.copyWith(fontSize: 16)),
                const Spacer(),
                Text(
                  '${controller.loadedFoodItems.length}'
                  '/${controller.totalFoodCount.value} món',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: controller.loadedFoodItems.length,
              itemBuilder: (context, index) => RepaintBoundary(
                child: _FeaturedFoodCard(
                  item: controller.loadedFoodItems[index],
                  onTap: () => controller.navigateToFoodDetail(
                      controller.loadedFoodItems[index]),
                ),
              ),
            ),
            if (controller.hasMoreFoods) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => controller.loadMoreFoods(),
                  icon: const Icon(Icons.expand_more_rounded),
                  label: const Text('Tải thêm món'),
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

class _FeaturedFoodCard extends StatelessWidget {
  final FoodItemModel item;
  final VoidCallback onTap;

  const _FeaturedFoodCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.isAvailable ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: item.imageUrl != null
                    ? AppNetworkImage(
                        url: item.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description!,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.price.toInt().toVnd()}đ',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primaryOrange,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
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
                                  );
                                }
                              : null,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: item.isAvailable
                                  ? AppColors.primaryOrange
                                  : AppColors.grey300,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: AppColors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.grey100,
      child: const Center(
        child:
            Icon(Icons.fastfood_rounded, color: AppColors.grey400, size: 40),
      ),
    );
  }
}
