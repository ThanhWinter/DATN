import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

import "../theme/app_colors.dart";
import "../theme/app_text_styles.dart";

/// Nút bấm chung cho login screen (Primary filled / Outline ghost).
/// Dùng chung cho các màn login/register trên nền gradient.
class GradientActionButton extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final Color iconColor;
  final String text;
  final bool isPrimary;
  final VoidCallback onTap;

  const GradientActionButton({
    super.key,
    this.icon,
    this.svgPath,
    required this.iconColor,
    required this.text,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: isPrimary
            ? AppColors.primaryOrange.withValues(alpha: 0.1)
            : AppColors.white.withValues(alpha: 0.1),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.white : AppColors.transparent,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isPrimary ? AppColors.transparent : AppColors.white,
              width: 1.5,
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              svgPath != null
                  ? SvgPicture.asset(
                      svgPath!,
                      colorFilter: ColorFilter.mode(
                        iconColor,
                        BlendMode.srcIn,
                      ),
                      width: 22,
                      height: 22,
                    )
                  : Icon(icon ?? Icons.help_outline,
                      color: iconColor, size: 22),
              const SizedBox(width: 12),
              Text(
                text,
                style: AppTextStyles.button.copyWith(
                  fontSize: 16,
                  color: isPrimary ? AppColors.textDark : AppColors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
