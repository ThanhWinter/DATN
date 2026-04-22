import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomePromoSection extends GetView<HomeController> {
  const HomePromoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.only(bottom: 16),
      child: Obx(() {
        final banners = controller.promoBanners;
        if (banners.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 148,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: banners.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return _BannerCard(
                title: banner.title,
                subtitle: banner.subtitle,
                badgeText: banner.badgeText,
                imageUrl: banner.imageUrl,
              );
            },
          ),
        );
      }),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeText;
  final String? imageUrl;

  const _BannerCard({
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 280,
        height: 148,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              AppNetworkImage(
                url: imageUrl!,
                fit: BoxFit.cover,
                errorWidget: _fallbackGradient(),
              )
            else
              _fallbackGradient(),

            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xEEF9A825), Color(0x44FF5252)],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText!,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentGold, AppColors.primaryOrange],
        ),
      ),
    );
  }
}
