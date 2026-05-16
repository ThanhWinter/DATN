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
  late final MenuController _menuController;
  Worker? _queryWorker;

  @override
  void initState() {
    super.initState();
    _menuController = Get.find<MenuController>();
    // Khôi phục text field nếu controller vẫn còn query (sau pull-to-refresh hoặc remount)
    final existing = _menuController.searchQuery.value;
    if (existing.isNotEmpty) {
      _ctrl.text = existing;
      _ctrl.selection = TextSelection.collapsed(offset: existing.length);
    }
    // Sync text field khi query bị reset từ bên ngoài (đổi tab, clear filter)
    _queryWorker = ever(_menuController.searchQuery, (q) {
      if (q.isEmpty && _ctrl.text.isNotEmpty) {
        _ctrl.clear();
      }
    });
  }

  @override
  void dispose() {
    _queryWorker?.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 20),
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: _menuController.updateSearch,
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm món ăn...',
                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
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
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.close_rounded, color: Color(0xFF9CA3AF), size: 18),
                  ),
                )
              : const SizedBox(width: 12)),
        ],
      ),
    );
  }
}
