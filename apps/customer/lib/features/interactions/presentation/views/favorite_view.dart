import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/interaction_models.dart';
import '../controllers/favorite_controller.dart';

class FavoriteView extends GetView<FavoriteController> {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Yêu thích', style: AppTextStyles.h2),
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        isEmpty: () => controller.isEmpty.value,
        emptyWidget: const _EmptyFavorite(),
        onSuccess: () => Obx(
          () => ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _FavoriteTile(
              item: controller.favorites[i],
              onTap: () =>
                  controller.navigateToFoodDetail(controller.favorites[i].foodId),
              onRemove: () =>
                  controller.removeFavorite(controller.favorites[i].foodId),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  final FavoriteItemModel item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imageUrl != null
                  ? AppNetworkImage(
                      url: item.imageUrl!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      memCacheWidth: 64,
                      memCacheHeight: 64,
                    )
                  : Container(
                      width: 64,
                      height: 64,
                      color: AppColors.grey200,
                      child: const Icon(Icons.fastfood_outlined,
                          color: AppColors.grey400),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.foodName,
                      style: AppTextStyles.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    '${item.price.toVnd()} ₫',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.primaryOrange),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.favorite, color: AppColors.errorRed),
              tooltip: 'Xóa khỏi yêu thích',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorite extends StatelessWidget {
  const _EmptyFavorite();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border,
              size: 72, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(
            'Chưa có món yêu thích',
            style:
                AppTextStyles.h3.copyWith(color: AppColors.textGrey),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn trái tim trên món ăn để lưu lại',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.grey400),
          ),
        ],
      ),
    );
  }
}
