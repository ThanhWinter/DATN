import 'package:get/get.dart';

import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';

class CustomerController extends GetxController {
  CustomerController(this._repository);

  final CustomerRepository _repository;

  final isLoading = true.obs;
  final error = Rxn<String>();

  // TODO: mock data
  final allCustomers = <CustomerModel>[].obs;
  final filteredCustomers = <CustomerModel>[].obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    isLoading.value = true;
    error.value = null;
    try {
      allCustomers.value = await _repository.fetchCustomers();
      filteredCustomers.value = List.of(allCustomers);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void search(String q) {
    searchQuery.value = q;
    final lower = q.toLowerCase();
    filteredCustomers.value = lower.isEmpty
        ? List.of(allCustomers)
        : allCustomers
            .where((c) =>
                c.fullName.toLowerCase().contains(lower) ||
                c.email.toLowerCase().contains(lower) ||
                c.phone.contains(lower))
            .toList();
  }

  void deleteCustomer(String id) {
    allCustomers.removeWhere((c) => c.id == id);
    filteredCustomers.removeWhere((c) => c.id == id);
  }
}
