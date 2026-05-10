import 'dart:async';
import 'dart:convert';

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../data/models/address_model.dart';
import '../controllers/address_controller.dart';

Future<List<String>> _searchNominatim(String query) async {
  if (query.trim().length < 3) return [];
  try {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query.trim(),
      'format': 'json',
      'limit': '5',
      'accept-language': 'vi',
    });
    final res = await http.get(uri, headers: {
      'User-Agent': 'FoodHitCustomerApp/1.0'
    }).timeout(const Duration(seconds: 6));
    if (res.statusCode != 200) return [];
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) =>
            (e as Map<String, dynamic>)['display_name']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  } catch (_) {
    return [];
  }
}

class AddressView extends GetView<AddressController> {
  const AddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final isPicker = args is Map && (args['isPicker'] as bool? ?? false);

    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: Text(
          isPicker ? 'Chọn địa chỉ' : 'Địa chỉ giao hàng',
          style: AppTextStyles.h3,
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SnapHelperWidget(
        isLoading: controller.isLoading,
        error: controller.error,
        onRetry: controller.loadAddresses,
        onSuccess: () => Obx(() {
          if (controller.addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_off_outlined,
                      size: 64, color: AppColors.grey300),
                  const SizedBox(height: 12),
                  const Text('Chưa có địa chỉ nào',
                      style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditSheet(context, null, isPicker),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Thêm địa chỉ mới'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: controller.addresses.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 64, endIndent: 16),
            itemBuilder: (_, i) {
              final addr = controller.addresses[i];
              return _AddressTile(
                address: addr,
                isPicker: isPicker,
                onSelect:
                    isPicker ? () => Get.back(result: addr.fullAddress) : null,
                onEdit: () => _showAddEditSheet(context, addr, isPicker),
                onDelete: () => controller.deleteAddress(addr.id),
                onSetDefault: () => controller.setDefault(addr.id),
              );
            },
          );
        }),
      ),
      bottomNavigationBar: isPicker
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddEditSheet(context, null, isPicker),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Thêm địa chỉ mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
    );
  }

  void _showAddEditSheet(
      BuildContext context, UserAddressModel? existing, bool isPicker) {
    Get.bottomSheet(
      _AddEditAddressSheet(existing: existing),
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

// ── Address tile ─────────────────────────────────────────────────────────────

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.isPicker,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    this.onSelect,
  });

  final UserAddressModel address;
  final bool isPicker;
  final VoidCallback? onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isPicker ? onSelect : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: address.isDefault
                    ? AppColors.primaryOrange.withValues(alpha: 0.12)
                    : AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 18,
                color: address.isDefault
                    ? AppColors.primaryOrange
                    : AppColors.grey600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (address.label != null &&
                          address.label!.isNotEmpty) ...[
                        Text(
                          address.label!,
                          style:
                              AppTextStyles.labelLarge.copyWith(fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (address.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Mặc định',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    address.fullAddress,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!isPicker)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                  if (value == 'default') onSetDefault();
                },
                icon: const Icon(Icons.more_vert,
                    size: 18, color: AppColors.grey600),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'default',
                    child: Row(children: [
                      Icon(Icons.star_outline_rounded,
                          size: 16, color: AppColors.primaryOrange),
                      SizedBox(width: 8),
                      Text('Đặt làm mặc định'),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Chỉnh sửa'),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      const Icon(Icons.delete_outline,
                          size: 16, color: AppColors.errorRed),
                      const SizedBox(width: 8),
                      Text(
                        'Xoá',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.errorRed),
                      ),
                    ]),
                  ),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.grey400),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Add / Edit sheet ──────────────────────────────────────────────────────────

class _AddEditAddressSheet extends StatefulWidget {
  const _AddEditAddressSheet({this.existing});

  final UserAddressModel? existing;

  @override
  State<_AddEditAddressSheet> createState() => _AddEditAddressSheetState();
}

class _AddEditAddressSheetState extends State<_AddEditAddressSheet> {
  late final TextEditingController _addressCtrl;
  late final TextEditingController _labelCtrl;
  late final AddressController _ctrl;
  Timer? _debounce;
  List<String> _suggestions = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<AddressController>();
    _addressCtrl =
        TextEditingController(text: widget.existing?.fullAddress ?? '');
    _labelCtrl = TextEditingController(text: widget.existing?.label ?? '');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addressCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  void _onAddressChanged(String val) {
    _debounce?.cancel();
    if (val.trim().length < 3) {
      setState(() {
        _suggestions = [];
        _searching = false;
      });
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
    _addressCtrl.text = address;
    _addressCtrl.selection = TextSelection.collapsed(offset: address.length);
    setState(() => _suggestions = []);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + keyboardHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.existing == null
                  ? 'Thêm địa chỉ mới'
                  : 'Chỉnh sửa địa chỉ',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelCtrl,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Nhãn (VD: Nhà, Công ty...)',
                prefixIcon: const Icon(Icons.label_outline,
                    size: 20, color: AppColors.primaryOrange),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.primaryOrange, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ── Address field with search ──────────────────────────────────
            TextField(
              controller: _addressCtrl,
              style: AppTextStyles.bodyLarge,
              maxLines: 2,
              minLines: 1,
              onChanged: _onAddressChanged,
              decoration: InputDecoration(
                labelText: 'Địa chỉ *',
                alignLabelWithHint: true,
                prefixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primaryOrange),
                        ),
                      )
                    : const Icon(Icons.location_on_outlined,
                        size: 20, color: AppColors.primaryOrange),
                suffixIcon: _addressCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            size: 16, color: AppColors.textGrey),
                        onPressed: () {
                          _addressCtrl.clear();
                          setState(() => _suggestions = []);
                        },
                      )
                    : null,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.primaryOrange, width: 1.5),
                ),
              ),
            ),
            // ── Suggestions list ──────────────────────────────────────────
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
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
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 44),
                  itemBuilder: (_, i) => InkWell(
                    onTap: () => _pickSuggestion(_suggestions[i]),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 16, color: AppColors.primaryOrange),
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
            const SizedBox(height: 16),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _ctrl.isSubmitting.value ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _ctrl.isSubmitting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(widget.existing == null
                            ? 'Lưu địa chỉ'
                            : 'Cập nhật'),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _save() {
    final address = _addressCtrl.text.trim();
    if (address.isEmpty) {
      Get.snackbar('Thiếu thông tin', 'Vui lòng nhập địa chỉ.',
          snackPosition: SnackPosition.TOP);
      return;
    }
    final label = _labelCtrl.text.trim();
    if (widget.existing == null) {
      _ctrl.createAddress(
        fullAddress: address,
        label: label.isEmpty ? null : label,
      );
    } else {
      _ctrl.updateAddress(
        id: widget.existing!.id,
        fullAddress: address,
        label: label.isEmpty ? null : label,
      );
    }
  }
}
