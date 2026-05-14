import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/home_category_section.dart';
import '../widgets/home_location_header.dart';
import '../widgets/home_popular_section.dart';
import '../widgets/home_promo_section.dart';

// ── Store Closed Banner ───────────────────────────────────────────────────────

class _StoreClosedBanner extends GetView<HomeController> {
  const _StoreClosedBanner();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isStoreOpen) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: const Color(0xFFFF3B30),
        child: const Text(
          'Cửa hàng đang đóng cửa — đơn sẽ được xử lý khi mở cửa lại',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }
}

// ── Skeleton Animation ────────────────────────────────────────────────────────

class _SkeletonPulse extends StatefulWidget {
  final Widget child;
  const _SkeletonPulse({required this.child});

  @override
  State<_SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<_SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.35, end: 0.80)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FadeTransition thay đổi opacity ở tầng GPU, không rebuild widget con
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

// ── Home Skeleton ─────────────────────────────────────────────────────────────

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header thật — không pulsate
        const HomeLocationHeader(),
        // Chỉ phần nội dung skeleton mới fade
        Expanded(child: _SkeletonPulse(child: _buildContent())),
      ],
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Banner skeleton
        _box(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            height: 160,
            radius: 12),
        const SizedBox(height: 12),

        // Category skeleton
        Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: _box(height: 14, width: 80, radius: 6),
              ),
              SizedBox(
                height: 78,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: List.generate(
                      5,
                      (i) => SizedBox(
                        width: 68,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _circle(size: 52),
                            const SizedBox(height: 5),
                            _box(height: 10, width: 44, radius: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Food grid skeleton — Column+Row thay vì GridView(shrinkWrap: true)
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _box(height: 15, width: 90, radius: 6),
              const SizedBox(height: 14),
              ...List.generate(
                  3,
                  (row) => Padding(
                        padding: EdgeInsets.only(top: row == 0 ? 0 : 10),
                        child: Row(children: [
                          Expanded(child: _foodCardSkeleton()),
                          const SizedBox(width: 10),
                          Expanded(child: _foodCardSkeleton()),
                        ]),
                      )),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _box({
    double? width,
    required double height,
    double radius = 8,
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0), // Solid — FadeTransition xử lý opacity
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  static Widget _circle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE0E0E0),
      ),
    );
  }

  static Widget _foodCardSkeleton() {
    // AspectRatio đảm bảo Expanded bên trong có bounded height
    return AspectRatio(
      aspectRatio: 0.78,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _box(height: 12, radius: 5),
                    _box(height: 11, width: 80, radius: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _box(height: 13, width: 60, radius: 5),
                        _circle(size: 28),
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
}

// ── HomeView ──────────────────────────────────────────────────────────────────

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient backdrop: xanh lá nhạt → trắng (chỉ phần đầu trang)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F5E9),
                  Colors.white,
                  Colors.white,
                ],
                stops: [0.0, 0.30, 1.0],
              ),
            ),
          ),
          SnapHelperWidget(
            isLoading: controller.isLoading,
            error: controller.error,
            onRetry: controller.loadData,
            loadingWidget: const _HomeSkeleton(),
            onSuccess: () => Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                const HomeLocationHeader(),

                // ── Store closed banner ──────────────────────────────────
                const _StoreClosedBanner(),

                // ── Scrollable content ───────────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.loadData,
                    color: AppColors.primaryOrange,
                    backgroundColor: AppColors.white,
                    child: const CustomScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: HomePromoSection()),
                        SliverToBoxAdapter(child: SizedBox(height: 8)),
                        SliverToBoxAdapter(child: HomeCategorySection()),
                        SliverToBoxAdapter(child: SizedBox(height: 8)),
                        SliverToBoxAdapter(child: HomePopularSection()),
                        SliverToBoxAdapter(child: SizedBox(height: 32)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
