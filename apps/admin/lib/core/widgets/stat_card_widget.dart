import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Shared stat card used in DashboardView (useGradient: true) and ProfileView (useGradient: false).
///
/// Dashboard style: coloured icon circle, ShaderMask value text, tinted border & shadow.
/// Profile style  : flat icon, flat-coloured value text, white card, neutral shadow.
class StatCardWidget extends StatelessWidget {
  const StatCardWidget({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.useGradient = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  /// When true → dashboard visual style (gradient value, coloured border/shadow, horizontal padding).
  /// When false → profile visual style (flat colour, white card, neutral shadow).
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: useGradient
            ? const EdgeInsets.symmetric(vertical: 14, horizontal: 10)
            : const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: useGradient
              ? AppColors.white.withValues(alpha: 0.75)
              : AppColors.white,
          borderRadius: BorderRadius.circular(useGradient ? 16 : 14),
          border: useGradient
              ? Border.all(color: color.withValues(alpha: 0.2), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: useGradient
                  ? color.withValues(alpha: 0.07)
                  : AppColors.black.withValues(alpha: 0.04),
              blurRadius: useGradient ? 12 : 8,
              offset: useGradient ? const Offset(0, 4) : const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildIcon(),
            SizedBox(height: useGradient ? 8 : 6),
            _buildValue(),
            const SizedBox(height: 2),
            _buildLabel(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (useGradient) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      );
    }
    return Icon(icon, size: 20, color: color);
  }

  Widget _buildValue() {
    if (useGradient) {
      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [color, color.withValues(alpha: 0.75)],
        ).createShader(bounds),
        child: Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }
    return Text(
      value,
      style: AppTextStyles.h3.copyWith(color: color, fontSize: 16),
    );
  }

  Widget _buildLabel() {
    if (useGradient) {
      return Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: 10,
          color: AppColors.textGrey,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text(
      label,
      style: AppTextStyles.bodySmall,
      textAlign: TextAlign.center,
    );
  }
}
