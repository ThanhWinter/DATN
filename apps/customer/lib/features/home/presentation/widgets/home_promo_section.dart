import "package:flutter/material.dart";
import "package:get/get.dart";

import "../controllers/home_controller.dart";
import "promo_banner_card.dart";

class HomePromoSection extends GetView<HomeController> {
  const HomePromoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final banner = controller.promoBanner.value;
      if (banner == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: SizedBox(
          height: 130,
          child: PromoBannerCard(
            item: banner,
            onTap: () => Get.snackbar(
              "Khuyến mãi",
              banner.title,
              snackPosition: SnackPosition.TOP,
            ),
          ),
        ),
      );
    });
  }
}
