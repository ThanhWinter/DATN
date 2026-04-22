import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileMenuCard extends StatelessWidget {
  final List<Widget> children;

  const ProfileMenuCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData? icon;
  final String? iconPath;
  final String? svgPath;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? labelColor;

  const ProfileMenuItem({
    super.key,
    this.icon,
    this.iconPath,
    this.svgPath,
    required this.label,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.labelColor,
  }) : assert(icon != null || iconPath != null || svgPath != null);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor != null
                    ? iconColor!.withValues(alpha: 0.1)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: _buildIcon(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(color: labelColor),
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey400,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final color = iconColor ?? AppColors.textGrey;
    if (svgPath != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgPicture.asset(
          svgPath!,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      );
    }
    if (iconPath != null) {
      return ImageIcon(
        AssetImage(iconPath!),
        color: color,
        size: 18,
      );
    }
    return Icon(
      icon,
      color: color,
      size: 18,
    );
  }
}

class ProfileMenuDivider extends StatelessWidget {
  const ProfileMenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppColors.grey300),
    );
  }
}

class ProfileMenuBadge extends StatelessWidget {
  final String count;

  const ProfileMenuBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class ProfileSectionLabel extends StatelessWidget {
  final String text;

  const ProfileSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}
