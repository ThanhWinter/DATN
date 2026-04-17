import "package:flutter/material.dart";

import "../theme/app_colors.dart";
import "../theme/app_text_styles.dart";

/// Input field phong cách glassmorphism trên nền gradient.
/// Dùng chung cho các màn login/register trên nền có gradient.
class GlassInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final int? maxLength;

  const GlassInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.readOnly = false,
    this.suffixIcon,
    this.keyboardType,
    this.onTap,
    this.maxLength,
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
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        maxLength: maxLength,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
        cursorColor: AppColors.accentGold,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.white.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(icon,
              color: AppColors.white.withValues(alpha: 0.8), size: 22),
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
