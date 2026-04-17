import "package:core_ui/core_ui.dart";
import "package:flutter/material.dart";

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to search screen
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.grey400, size: 22),
              const SizedBox(width: 12),
              Text(
                "Tìm món ăn bạn muốn...",
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.grey400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
