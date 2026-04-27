import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/home_items.dart';
import '../controllers/home_controller.dart';

class HomePopularSection extends GetView<HomeController> {
  const HomePopularSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.featuredItems.isEmpty) return const SizedBox.shrink();

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
                Text('Nổi bật', style: AppTextStyles.h3.copyWith(fontSize: 16)),
                const Spacer(),
                Text(
                  '${controller.featuredItems.length} món',
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
              itemCount: controller.featuredItems.length,
              itemBuilder: (context, index) => RepaintBoundary(
                child: _FeaturedFoodCard(
                  item: controller.featuredItems[index],
                  onTap: () =>
                      controller.navigateToFoodDetail(controller.featuredItems[index]),
                ),
              ),
            ),
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
                        memCacheWidth: 200,
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
                          '${(item.price / 1000).round()}K',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primaryOrange,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: item.isAvailable
                                ? AppColors.primaryOrange
                                : AppColors.grey300,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.white,
                            size: 14,
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
