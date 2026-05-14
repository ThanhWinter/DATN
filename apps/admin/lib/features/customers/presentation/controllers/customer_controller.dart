import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';
import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';

class CustomerController extends GetxController {
  CustomerController(this._repository);

  final CustomerRepository _repository;

  // --- Tab Khách hàng (CUSTOMER role) ---
  final allCustomers = <CustomerModel>[].obs;
  final filteredCustomers = <CustomerModel>[].obs;
  final isLoadingCustomers = true.obs;
  final errorCustomers = Rxn<String>();
  final searchCustomerQuery = ''.obs;
  final List<String> _searchKeysCustomers = [];

  // --- Tab Admin (ADMIN role) ---
  final allAdmins = <CustomerModel>[].obs;
  final filteredAdmins = <CustomerModel>[].obs;
  final isLoadingAdmins = true.obs;
  final errorAdmins = Rxn<String>();
  final searchAdminQuery = ''.obs;
  final List<String> _searchKeysAdmins = [];

  // --- Shared ---
  final isMutating = false.obs;
  final selectedCustomer = Rxn<CustomerModel>();
  final isLoadingDetail = false.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(
      searchCustomerQuery,
      (_) => _applySearchCustomers(searchCustomerQuery.value),
      time: const Duration(milliseconds: 400),
    );
    debounce(
      searchAdminQuery,
      (_) => _applySearchAdmins(searchAdminQuery.value),
      time: const Duration(milliseconds: 400),
    );
    loadAll();
  }

  Future<void> loadAll() async {
    await Future.wait([loadCustomers(), loadAdmins()]);
  }

  Future<void> loadCustomers() async {
    dev.log('[USER/VM] Loading customers...');
    isLoadingCustomers.value = true;
    errorCustomers.value = null;
    try {
      final list = await _repository.fetchCustomers(role: 'USER');
      allCustomers.value = list;
      _searchKeysCustomers
        ..clear()
        ..addAll(list.map(
            (c) => '${c.fullName} ${c.email} ${c.phone}'.toLowerCase()));
      _applySearchCustomers(searchCustomerQuery.value);
      dev.log('[USER/VM] ✅ Loaded ${list.length} customers');
    } catch (e) {
      dev.log('[USER/VM] ❌ loadCustomers error: $e');
      errorCustomers.value = e.toString();
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  Future<void> loadAdmins() async {
    dev.log('[USER/VM] Loading admins...');
    isLoadingAdmins.value = true;
    errorAdmins.value = null;
    try {
      final list = await _repository.fetchCustomers(role: 'ADMIN');
      allAdmins.value = list;
      _searchKeysAdmins
        ..clear()
        ..addAll(list.map(
            (a) => '${a.fullName} ${a.email} ${a.phone}'.toLowerCase()));
      _applySearchAdmins(searchAdminQuery.value);
      dev.log('[USER/VM] ✅ Loaded ${list.length} admins');
    } catch (e) {
      dev.log('[USER/VM] ❌ loadAdmins error: $e');
      errorAdmins.value = e.toString();
    } finally {
      isLoadingAdmins.value = false;
    }
  }

  void searchCustomers(String q) => searchCustomerQuery.value = q;
  void searchAdmins(String q) => searchAdminQuery.value = q;

  void _applySearchCustomers(String q) {
    final lower = q.toLowerCase().trim();
    if (lower.isEmpty) {
      filteredCustomers.value = List.of(allCustomers);
      return;
    }
    filteredCustomers.value = [
      for (var i = 0; i < allCustomers.length; i++)
        if (_searchKeysCustomers[i].contains(lower)) allCustomers[i],
    ];
  }

  void _applySearchAdmins(String q) {
    final lower = q.toLowerCase().trim();
    if (lower.isEmpty) {
      filteredAdmins.value = List.of(allAdmins);
      return;
    }
    filteredAdmins.value = [
      for (var i = 0; i < allAdmins.length; i++)
        if (_searchKeysAdmins[i].contains(lower)) allAdmins[i],
    ];
  }

  Future<void> loadCustomerDetail(String id) async {
    dev.log('[USER/VM] Loading detail for id=$id');
    isLoadingDetail.value = true;
    selectedCustomer.value = null;
    try {
      selectedCustomer.value = await _repository.getCustomerDetail(id);
    } catch (e) {
      dev.log('[USER/VM] ❌ loadCustomerDetail error: $e');
      Get.snackbar('Lỗi', 'Không thể tải thông tin người dùng: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Khoá tài khoản khách hàng (soft delete — backend setIsActive=false).
  /// Chỉ áp dụng cho CUSTOMER, không áp dụng cho ADMIN.
  Future<void> lockCustomer(String id) async {
    dev.log('[USER/VM] Locking customer id=$id');
    isMutating.value = true;
    try {
      await _repository.deleteCustomer(id);
      // Reload để user thấy badge "Đã khoá" thay vì biến mất khỏi danh sách
      await loadCustomers();
      Get.snackbar(
        'Đã khoá',
        'Tài khoản khách hàng đã bị khoá',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      dev.log('[USER/VM] ✅ Customer $id locked');
    } on ApiException catch (e) {
      dev.log('[USER/VM] ❌ lockCustomer ApiException: ${e.statusCode} ${e.message}');
      final msg = e.statusCode == 409
          ? 'Khách hàng đang có đơn hàng chưa hoàn tất, không thể khoá tài khoản.'
          : e.message;
      Get.snackbar('Không thể khoá', msg,
          backgroundColor: AppColors.errorRed,
          colorText: AppColors.white,
          duration: const Duration(seconds: 4));
    } catch (e) {
      dev.log('[USER/VM] ❌ lockCustomer error: $e');
      Get.snackbar('Lỗi', 'Không thể khoá tài khoản: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> unlockCustomer(String id) async {
    dev.log('[USER/VM] Unlocking customer id=$id');
    isMutating.value = true;
    try {
      await _repository.unlockCustomer(id);
      await loadCustomers();
      Get.snackbar(
        'Đã mở khoá',
        'Tài khoản khách hàng đã được mở khoá',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      dev.log('[USER/VM] ✅ Customer $id unlocked');
    } catch (e) {
      dev.log('[USER/VM] ❌ unlockCustomer error: $e');
      Get.snackbar('Lỗi', 'Không thể mở khoá tài khoản: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isMutating.value = false;
    }
  }
}
