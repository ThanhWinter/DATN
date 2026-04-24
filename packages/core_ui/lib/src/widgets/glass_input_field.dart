import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

import "../theme/app_colors.dart";
import "../theme/app_text_styles.dart";

class GlassInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final String? svgPath;
  final bool obscureText;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final int? maxLength;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  const GlassInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.svgPath,
    this.obscureText = false,
    this.readOnly = false,
    this.suffixIcon,
    this.keyboardType,
    this.onTap,
    this.maxLength,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        maxLength: maxLength,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted != null ? (_) => onSubmitted!() : null,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
        cursorColor: AppColors.accentGold,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.white.withValues(alpha: 0.6),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(16),
            child: svgPath != null
                ? SvgPicture.asset(
                    svgPath!,
                    colorFilter: ColorFilter.mode(
                      AppColors.white.withValues(alpha: 0.8),
                      BlendMode.srcIn,
                    ),
                    width: 20,
                    height: 20,
                  )
                : Icon(
                    icon ?? Icons.help_outline,
                    color: AppColors.white.withValues(alpha: 0.8),
                    size: 22,
                  ),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          counterText: "",
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
