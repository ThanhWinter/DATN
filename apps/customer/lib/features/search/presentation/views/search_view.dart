import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../home/data/models/home_items.dart';
import '../controllers/food_search_controller.dart';

class SearchView extends GetView<FoodSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: Get.back,
        ),
        title: TextField(
          controller: controller.searchCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tìm món ăn...',
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
            border: InputBorder.none,
            suffixIcon: Obx(
              () => controller.hasQuery.value
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 20, color: AppColors.textGrey),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          style: AppTextStyles.bodyLarge,
          textInputAction: TextInputAction.search,
        ),
      ),
      body: Obx(() {
        if (!controller.hasQuery.value) return const _SearchPrompt();
        if (controller.isEmpty.value) {
          return const AppEmptyState(
            icon: Icons.search_off_rounded,
            message: 'Không tìm thấy kết quả',
            subMessage: 'Thử từ khóa khác nhé!',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.results.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 80, endIndent: 16),
          itemBuilder: (_, i) => _ResultTile(
            food: controller.results[i],
            onTap: () => controller.navigateToDetail(controller.results[i]),
          ),
        );
      }),
    );
  }
}

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_rounded,
            size: 72,
            color: AppColors.textLight.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 12),
          Text(
            'Nhập tên món ăn để tìm kiếm',
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.food, required this.onTap});

  final FoodItemModel food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            AppNetworkImage(
              url: food.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: AppTextStyles.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (food.categoryName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      food.categoryName!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        food.price.toVnd(),
                        style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryOrange),
                      ),
                      if (!food.isAvailable) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Hết hàng',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.errorRed),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }
}
