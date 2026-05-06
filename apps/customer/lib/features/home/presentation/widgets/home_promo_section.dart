import 'dart:async';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

/// Banner carousel — ảnh do admin upload từ màn hình quản lý banner.
/// Tự động cuộn 4 giây / lần; dừng khi người dùng chạm vào.
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
    _timer?.cancel();
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
    return Obx(() {
      final banners = _ctrl.promoBanners;
      if (banners.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ──────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Ưu đãi đặc biệt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),

          // ── Banner carousel ─────────────────────────────────────────────
          Listener(
            onPointerDown: (_) {
              _timer?.cancel();
              _timer = null;
            },
            onPointerUp: (_) => _startAutoScroll(),
            child: SizedBox(
              height: 168,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: banners.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _BannerCard(
                    title: banners[i].title,
                    imageUrl: banners[i].imageUrl,
                  ),
                ),
              ),
            ),
          ),

          // ── Dot indicators ──────────────────────────────────────────────
          if (banners.length > 1) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(banners.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primaryOrange
                        : const Color(0xFFD5D5D5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: 6),
        ],
      );
    });
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
        height: 168,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background: admin-uploaded image ───────────────────────────
            if (imageUrl != null)
              AppNetworkImage(
                url: imageUrl!,
                fit: BoxFit.cover,
                errorWidget: _fallback(),
              )
            else
              _fallback(),

            // ── Gradient overlay for text legibility (bottom only) ─────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 90,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Banner title ────────────────────────────────────────────────
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.primaryOrange,
      child: const Center(
        child: Text(
          'Ưu đãi hôm nay',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
