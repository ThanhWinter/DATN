import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../controllers/menu_controller.dart';

/// Thanh tìm kiếm gắn [MenuController.updateSearch].
class MenuSearchBar extends StatefulWidget {
  const MenuSearchBar({super.key});

  @override
  State<MenuSearchBar> createState() => _MenuSearchBarState();
}

class _MenuSearchBarState extends State<MenuSearchBar> {
  final _ctrl = TextEditingController();
  late final MenuController _menuController;

  @override
  void initState() {
    super.initState();
    _menuController = Get.find<MenuController>();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.grey600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: _menuController.updateSearch,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm món ăn...',
                hintStyle: AppTextStyles.bodySmall,
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Obx(() => _menuController.searchQuery.value.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _ctrl.clear();
                    _menuController.updateSearch('');
                  },
                  child: const Icon(Icons.close,
                      color: AppColors.grey400, size: 18),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
