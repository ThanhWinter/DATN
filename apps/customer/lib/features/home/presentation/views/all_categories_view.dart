import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/home_items.dart';
import '../controllers/home_controller.dart';

class AllCategoriesView extends StatelessWidget {
  const AllCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textDark),
          onPressed: Get.back,
        ),
        title: const Text(
          'Danh mục',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final cats = controller.categories;
        if (cats.isEmpty) {
          return const Center(
            child: Text('Không có danh mục',
                style: TextStyle(color: AppColors.textGrey)),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 20,
            crossAxisSpacing: 8,
            childAspectRatio: 0.78,
          ),
          itemCount: cats.length,
          itemBuilder: (context, i) {
            final cat = cats[i];
            return Obx(() => _CategoryGridItem(
                  cat: cat,
                  isSelected: controller.selectedCategoryId.value == cat.id,
                  onTap: () {
                    controller.selectCategory(cat.id);
                    Get.back();
                  },
                ));
          },
        );
      }),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  final CategoryItem cat;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryGridItem({
    required this.cat,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.primaryOrange.withValues(alpha: 0.12)
                  : const Color(0xFFF5F5F5),
              border: Border.all(
                color:
                    isSelected ? AppColors.primaryOrange : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryOrange.withValues(alpha: 0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: ClipOval(
              child: cat.imageUrl != null
                  ? AppNetworkImage(
                      url: cat.imageUrl!,
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                      errorWidget: _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            cat.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primaryOrange : AppColors.textGrey,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: isSelected
          ? AppColors.primaryOrange.withValues(alpha: 0.08)
          : const Color(0xFFF5F5F5),
      child: Center(
        child: Text(
          cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isSelected ? AppColors.primaryOrange : AppColors.grey400,
          ),
        ),
      ),
    );
  }
}
