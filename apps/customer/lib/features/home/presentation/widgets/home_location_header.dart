import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../main/presentation/controllers/main_controller.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/home_controller.dart';
import 'location_picker_sheet.dart';

class HomeLocationHeader extends StatelessWidget {
  const HomeLocationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 22, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── User avatar (initials) ────────────────────────────────
                  _UserAvatar(),
                  SizedBox(width: 10),

                  // ── Delivery address ──────────────────────────────────────
                  Expanded(child: _DeliveryAddress()),

                  // ── Notification + Cart ───────────────────────────────────
                  _NotificationBell(),
                  SizedBox(width: 4),
                  _CartButton(),
                ],
              ),
            ),
            SizedBox(height: 14),
            _SearchBar(),
            SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

// ── User Avatar (initials circle) ─────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.editProfile),
      child: Obx(() {
        final profile = Get.find<ProfileController>().user.value;
        final initials = _initials(profile?.firstName, profile?.lastName);
        return Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFFFE8D6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryOrange,
              ),
            ),
          ),
        );
      }),
    );
  }

  String _initials(String? first, String? last) {
    final f = first?.isNotEmpty == true ? first![0].toUpperCase() : '';
    final l = last?.isNotEmpty == true ? last![0].toUpperCase() : '';
    if (f.isEmpty && l.isEmpty) return '?';
    return '$f$l';
  }
}

// ── Delivery Address (tapable) ────────────────────────────────────────────────

class _DeliveryAddress extends GetView<HomeController> {
  const _DeliveryAddress();

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
            final name = controller.locationName.value;
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
  const _NotificationBell();

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
            Obx(() {
              final count =
                  Get.find<NotificationController>().unreadCount.value;
              if (count == 0) return const SizedBox.shrink();
              return Positioned(
                top: 5,
                right: 4,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1.5),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Cart Button ───────────────────────────────────────────────────────────────

class _CartButton extends StatelessWidget {
  const _CartButton();

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
            Obx(() {
              final count =
                  Get.find<MainController>().cartItemBadgeCount.value;
              if (count == 0) return const SizedBox.shrink();
              return Positioned(
                top: 5,
                right: 3,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
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
                ),
              );
            }),
          ],
        ),
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
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
