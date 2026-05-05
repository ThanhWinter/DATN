import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../data/models/profile_models.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      backgroundColor: AppColors.primaryOrangeDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryOrangeDark,
                AppColors.primaryOrange,
                AppColors.primaryOrangeLight,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ProfileAvatar(
                      initials: user.initials, avatarUrl: user.avatarUrl),
                  const SizedBox(width: 16),
                  Expanded(child: _UserInfo(user: user)),
                  const SizedBox(width: 12),
                  const _EditButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String initials;
  final String? avatarUrl;

  const _ProfileAvatar({required this.initials, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.25),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.7),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? AppNetworkImage(
                url: avatarUrl!,
                fit: BoxFit.cover,
                errorWidget: _initialsChild(),
              )
            : _initialsChild(),
      ),
    );
  }

  Widget _initialsChild() => Center(
        child: Text(
          initials,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

class _UserInfo extends StatelessWidget {
  final UserModel user;

  const _UserInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          user.fullName,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        _IconRow(icon: Icons.phone_outlined, text: user.phone),
        const SizedBox(height: 3),
        _IconRow(
          icon: Icons.mail_outline_rounded,
          text: user.email,
          flexible: true,
        ),
      ],
    );
  }
}

class _IconRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool flexible;

  const _IconRow({
    required this.icon,
    required this.text,
    this.flexible = false,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.white.withValues(alpha: 0.9),
      ),
      overflow: flexible ? TextOverflow.ellipsis : null,
    );

    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 5),
        flexible ? Flexible(child: textWidget) : textWidget,
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.editProfile),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.4),
          ),
        ),
        child: const Icon(
          Icons.edit_outlined,
          color: AppColors.white,
          size: 18,
        ),
      ),
    );
  }
}
