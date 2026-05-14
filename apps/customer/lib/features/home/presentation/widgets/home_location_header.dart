import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../main/presentation/controllers/main_controller.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/home_controller.dart';
import 'location_picker_sheet.dart';

/// Header toàn bộ trang chủ.
///
/// Các controller được resolve **một lần duy nhất** trong `build()` của widget gốc,
/// sau đó Rx-value được truyền xuống sub-widget qua constructor.
/// Điều này đảm bảo:
/// - `Get.find<T>()` KHÔNG bao giờ được gọi bên trong `Obx()` callback.
/// - Nếu một controller chưa được đăng ký (e.g. race condition lúc khởi động),
///   toàn bộ header vẫn render thay vì crash.
class HomeLocationHeader extends StatelessWidget {
  const HomeLocationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Resolve controllers một lần — O(1) HashMap lookup, KHÔNG phải trong Obx.
    final homeCtrl = Get.find<HomeController>();
    final profileCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : null;
    final notifCtrl = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : null;
    final mainCtrl =
        Get.isRegistered<MainController>() ? Get.find<MainController>() : null;

    return ColoredBox(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _UserAvatar(profileCtrl: profileCtrl),
                  const SizedBox(width: 10),
                  Expanded(
                    child:
                        _DeliveryAddress(locationName: homeCtrl.locationName),
                  ),
                  // RepaintBoundary cô lập các badge — khi badge đổi giá trị,
                  // chỉ widget con đó repaint, không kéo theo cả Row.
                  RepaintBoundary(
                    child:
                        _NotificationBell(unreadCount: notifCtrl?.unreadCount),
                  ),
                  const SizedBox(width: 4),
                  RepaintBoundary(
                    child:
                        _CartButton(badgeCount: mainCtrl?.cartItemBadgeCount),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _SearchBar(),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

// ── User Avatar ───────────────────────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.profileCtrl});

  final ProfileController? profileCtrl;

  static String _initials(String? first, String? last) {
    final f = first?.isNotEmpty == true ? first![0].toUpperCase() : '';
    final l = last?.isNotEmpty == true ? last![0].toUpperCase() : '';
    if (f.isEmpty && l.isEmpty) return '?';
    return '$f$l';
  }

  static const TextStyle _kStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryOrange,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.editProfile),
      child: profileCtrl == null
          ? _buildContainer(avatarUrl: null, initials: '?')
          : Obx(() {
              final u = profileCtrl!.user.value;
              return _buildContainer(
                avatarUrl: u?.avatarUrl,
                initials: _initials(u?.firstName, u?.lastName),
              );
            }),
    );
  }

  Widget _buildContainer({required String? avatarUrl, required String initials}) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFFFE8D6),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? AppNetworkImage(
                url: avatarUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorWidget: Center(child: Text(initials, style: _kStyle)),
              )
            : Center(child: Text(initials, style: _kStyle)),
      ),
    );
  }
}

// ── Delivery Address ──────────────────────────────────────────────────────────

class _DeliveryAddress extends StatelessWidget {
  const _DeliveryAddress({required this.locationName});

  // Nhận Rx trực tiếp thay vì cả controller — tách biệt dependency.
  final RxString locationName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openLocationPicker,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giao đến',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textLight,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Obx(() {
            final name = locationName.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    name.isEmpty ? 'Thêm địa chỉ' : name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: name.isEmpty
                          ? AppColors.textLight
                          : AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.primaryOrange,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

void _openLocationPicker() {
  Get.bottomSheet(
    const LocationPickerSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
  );
}

// ── Notification Bell ─────────────────────────────────────────────────────────

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.unreadCount});

  final RxInt? unreadCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.notifications),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Icon tĩnh — không bao giờ rebuild.
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEEEEEE)),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_outlined,
                size: 20,
                color: AppColors.textDark,
              ),
            ),
            // Chỉ badge nhỏ này rebuild khi count thay đổi.
            if (unreadCount != null)
              Obx(() => unreadCount!.value == 0
                  ? const SizedBox.shrink()
                  : const Positioned(
                      top: 5,
                      right: 4,
                      child: _UnreadDot(),
                    )),
          ],
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: AppColors.errorRed,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 1.5),
      ),
    );
  }
}

// ── Cart Button ───────────────────────────────────────────────────────────────

class _CartButton extends StatelessWidget {
  const _CartButton({required this.badgeCount});

  final RxInt? badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.cart),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Icon tĩnh — không bao giờ rebuild.
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEEEEEE)),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 20,
                color: AppColors.textDark,
              ),
            ),
            if (badgeCount != null)
              Obx(() {
                final count = badgeCount!.value;
                return count == 0
                    ? const SizedBox.shrink()
                    : Positioned(
                        top: 5,
                        right: 3,
                        child: _CartBadge(count: count),
                      );
              }),
          ],
        ),
      ),
    );
  }
}

/// Badge riêng biệt — `const` khi count không đổi nhờ Flutter's element reuse.
class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.white, width: 1.5),
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.search),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.textLight, size: 20),
              SizedBox(width: 10),
              Text(
                'Bạn muốn ăn gì hôm nay?',
                style: TextStyle(fontSize: 13, color: AppColors.textLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
