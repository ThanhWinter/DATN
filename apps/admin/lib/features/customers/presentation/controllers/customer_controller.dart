import 'dart:developer' as dev;

import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';

class CustomerController extends GetxController {
  CustomerController(this._repository);

  final CustomerRepository _repository;

  final isLoading = true.obs;
  final error = Rxn<String>();
  final isMutating = false.obs;

  final allCustomers = <CustomerModel>[].obs;
  final filteredCustomers = <CustomerModel>[].obs;
  final searchQuery = ''.obs;

  // Detail sheet state
  final selectedCustomer = Rxn<CustomerModel>();
  final isLoadingDetail = false.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(
      searchQuery,
      (_) => _applySearch(searchQuery.value),
      time: const Duration(milliseconds: 400),
    );
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    dev.log('[CUSTOMER/VM] Loading customers...');
    isLoading.value = true;
    error.value = null;
    try {
      allCustomers.value = await _repository.fetchCustomers();
      _applySearch(searchQuery.value);
      dev.log('[CUSTOMER/VM] ✅ Loaded ${allCustomers.length} customers');
    } catch (e) {
      dev.log('[CUSTOMER/VM] ❌ loadCustomers error: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void search(String q) {
    searchQuery.value = q;
    // filter chạy sau 400ms qua debounce worker ở onInit
  }

  void _applySearch(String q) {
    final lower = q.toLowerCase().trim();
    filteredCustomers.value = lower.isEmpty
        ? List.of(allCustomers)
        : allCustomers
            .where((c) =>
                c.fullName.toLowerCase().contains(lower) ||
                c.email.toLowerCase().contains(lower) ||
                c.phone.contains(lower))
            .toList();
  }

  Future<void> loadCustomerDetail(String id) async {
    dev.log('[CUSTOMER/VM] Loading detail for id=$id');
    isLoadingDetail.value = true;
    selectedCustomer.value = null;
    try {
      selectedCustomer.value = await _repository.getCustomerDetail(id);
      dev.log('[CUSTOMER/VM] ✅ Detail loaded: ${selectedCustomer.value?.email}');
    } catch (e) {
      dev.log('[CUSTOMER/VM] ❌ loadCustomerDetail error: $e');
      Get.snackbar('Lỗi', 'Không thể tải thông tin khách hàng: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> deleteCustomer(String id) async {
    dev.log('[CUSTOMER/VM] Deleting customer id=$id');
    isMutating.value = true;
    try {
      await _repository.deleteCustomer(id);
      allCustomers.removeWhere((c) => c.id == id);
      filteredCustomers.removeWhere((c) => c.id == id);
      Get.snackbar(
        'Đã xoá',
        'Khách hàng đã bị xoá khỏi hệ thống',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      dev.log('[CUSTOMER/VM] ✅ Customer $id deleted');
    } catch (e) {
      dev.log('[CUSTOMER/VM] ❌ deleteCustomer error: $e');
      Get.snackbar('Lỗi', 'Không thể xoá khách hàng: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.white);
    } finally {
      isMutating.value = false;
    }
  }
}
