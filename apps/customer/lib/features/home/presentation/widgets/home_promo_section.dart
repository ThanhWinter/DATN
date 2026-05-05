import 'dart:async';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomePromoSection extends StatefulWidget {
  const HomePromoSection({super.key});

  @override
  State<HomePromoSection> createState() => _HomePromoSectionState();
}

class _HomePromoSectionState extends State<HomePromoSection> {
  final _ctrl = Get.find<HomeController>();
  late final PageController _pageCtrl;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final count = _ctrl.promoBanners.length;
      if (count <= 1 || !_pageCtrl.hasClients) return;
      final next = (_currentPage + 1) % count;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.only(bottom: 16),
      child: Obx(() {
        final banners = _ctrl.promoBanners;
        if (banners.isEmpty) return const SizedBox.shrink();

        final showDots = banners.length > 1;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 148,
              child: Listener(
                onPointerDown: (_) {
                  _timer?.cancel();
                  _timer = null;
                },
                onPointerUp: (_) => _startAutoScroll(),
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: banners.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) {
                    final banner = banners[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _BannerCard(
                        title: banner.title,
                        imageUrl: banner.imageUrl,
                      ),
                    );
                  },
                ),
              ),
            ),
            if (showDots) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(banners.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryOrange
                          : AppColors.grey300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final String title;
  final String? imageUrl;

  const _BannerCard({required this.title, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 148,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              AppNetworkImage(
                url: imageUrl!,
                fit: BoxFit.cover,
                height: 148,
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
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
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

  Widget _fallbackGradient() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accentGold, AppColors.primaryOrange],
          ),
        ),
      );
}
