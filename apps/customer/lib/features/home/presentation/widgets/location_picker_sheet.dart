import 'dart:async';
import 'dart:convert';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../controllers/home_controller.dart';

Future<List<String>> _searchNominatim(String query) async {
  if (query.trim().length < 3) return [];
  try {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query.trim(),
      'format': 'json',
      'limit': '5',
      'accept-language': 'vi',
    });
    final res = await http
        .get(uri, headers: {'User-Agent': 'FoodHitCustomerApp/1.0 (contact@foodhit.vn)'})
        .timeout(const Duration(seconds: 6));
    if (res.statusCode != 200) return [];
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => (e as Map<String, dynamic>)['display_name']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  } catch (_) {
    return [];
  }
}

class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  late final HomeController _controller;
  late final TextEditingController _textController;
  late final Worker _addressWorker;
  Timer? _debounce;
  List<String> _suggestions = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HomeController>();
    _textController = TextEditingController(text: _controller.pickerAddress.value);

    // Khi GPS lấy được địa chỉ mới → cập nhật text field và xóa gợi ý
    _addressWorker = ever(_controller.pickerAddress, (String address) {
      if (_textController.text != address) {
        _textController.text = address;
        _textController.selection = TextSelection.collapsed(offset: address.length);
        if (mounted) setState(() => _suggestions = []);
      }
    });

    _controller.initPickerLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addressWorker.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onAddressChanged(String val) {
    _controller.updatePickerAddress(val);
    _debounce?.cancel();
    if (val.trim().length < 3) {
      if (_suggestions.isNotEmpty || _searching) {
        setState(() {
          _suggestions = [];
          _searching = false;
        });
      }
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      final results = await _searchNominatim(val);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _searching = false;
      });
    });
  }

  void _pickSuggestion(String address) {
    _textController.text = address;
    _textController.selection = TextSelection.collapsed(offset: address.length);
    _controller.updatePickerAddress(address);
    setState(() => _suggestions = []);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ─────────────────────────────────────────────────────
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // ── Tiêu đề ────────────────────────────────────────────────────
            const Text('Địa chỉ giao hàng', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            const Text(
              'Nhập địa chỉ hoặc lấy vị trí hiện tại của bạn',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),

            // ── Text field địa chỉ ─────────────────────────────────────────
            TextField(
              controller: _textController,
              onChanged: _onAddressChanged,
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              minLines: 1,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Nhập địa chỉ giao hàng...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
                prefixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primaryOrange,
                        size: 20,
                      ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.textGrey),
                  onPressed: () {
                    _textController.clear();
                    _controller.updatePickerAddress('');
                    setState(() => _suggestions = []);
                  },
                ),
                filled: true,
                fillColor: AppColors.grey100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryOrange,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // ── Danh sách gợi ý địa chỉ ───────────────────────────────────
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 44),
                  itemBuilder: (_, i) => InkWell(
                    onTap: () => _pickSuggestion(_suggestions[i]),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.primaryOrange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _suggestions[i],
                              style: AppTextStyles.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),

            // ── Nút lấy GPS ────────────────────────────────────────────────
            Obx(() {
              final locating = _controller.isLocating.value;
              return OutlinedButton.icon(
                onPressed: locating ? null : _controller.fetchCurrentLocation,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryOrange,
                  side: const BorderSide(color: AppColors.primaryOrange),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                icon: locating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryOrange,
                        ),
                      )
                    : const Icon(Icons.my_location_rounded, size: 18),
                label: Text(
                  locating ? 'Đang lấy vị trí...' : 'Dùng vị trí hiện tại',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primaryOrange,
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),

            // ── Xác nhận ───────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _controller.confirmPickerLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Xác nhận', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
