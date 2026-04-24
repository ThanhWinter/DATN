import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/customer_model.dart';

class CustomerRepository {
  CustomerRepository(this._apiClient);

  final IApiClient _apiClient;

  /// GET /users — Spring Page response: result.content = List<UserResponse>
  /// NOTE: Backend UserResponse chưa có trường `id` — CustomerModel.id sẽ dùng email
  /// làm fallback cho đến khi backend thêm id vào UserResponse.
  Future<List<CustomerModel>> fetchCustomers({int page = 0, int size = 50}) async {
    dev.log('[CUSTOMER/REPO] Fetching customers... page=$page size=$size');
    final res = await _apiClient.get(
      '/users',
      query: {'page': '$page', 'size': '$size'},
    );

    // Tuỳ backend trả List thẳng hay Page object
    final result = res['result'];
    final List<dynamic> list = result is List
        ? result
        : (result as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];

    dev.log('[CUSTOMER/REPO] ✅ Got ${list.length} customers');
    return list
        .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CustomerModel> getCustomerDetail(String id) async {
    dev.log('[CUSTOMER/REPO] Fetching customer detail: $id');
    final res = await _apiClient.get('/users/$id');
    final model =
        CustomerModel.fromJson(res['result'] as Map<String, dynamic>);
    dev.log('[CUSTOMER/REPO] ✅ Customer detail loaded: ${model.email}');
    return model;
  }

  Future<void> deleteCustomer(String id) async {
    dev.log('[CUSTOMER/REPO] Deleting customer id=$id');
    await _apiClient.delete('/users/$id');
    dev.log('[CUSTOMER/REPO] ✅ Customer $id deleted');
  }
}
