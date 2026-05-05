import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../controllers/menu_controller.dart';

class MenuSearchBar extends StatefulWidget {
  const MenuSearchBar({super.key});

  @override
  State<MenuSearchBar> createState() => _MenuSearchBarState();
}

class _MenuSearchBarState extends State<MenuSearchBar> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  late final MenuController _menuController;

  @override
  void initState() {
    super.initState();
    _menuController = Get.find<MenuController>();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 46,
      decoration: BoxDecoration(
        color: isFocused
            ? AppColors.white
            : AppColors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused
              ? AppColors.emerald
              : AppColors.emerald.withValues(alpha: 0.15),
          width: isFocused ? 1.5 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.emerald.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isFocused ? AppColors.emerald : AppColors.grey400,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              onChanged: _menuController.updateSearch,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món ăn...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              cursorColor: AppColors.emerald,
            ),
          ),
          Obx(() => _menuController.searchQuery.value.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _ctrl.clear();
                    _menuController.updateSearch('');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.emerald, size: 14),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
