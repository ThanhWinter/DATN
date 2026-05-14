import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/customer_model.dart';

class CustomerRepository {
  CustomerRepository(this._apiClient);

  final IApiClient _apiClient;

  /// GET /users — Spring Page response: result.content = List<UserResponse>
  /// [role] lọc theo vai trò: 'CUSTOMER' | 'ADMIN' | null (tất cả).
  Future<List<CustomerModel>> fetchCustomers(
      {int page = 0, int size = 50, String? role}) async {
    dev.log('[CUSTOMER/REPO] Fetching users... page=$page size=$size role=$role');
    final query = <String, String>{'page': '$page', 'size': '$size'};
    if (role != null) query['role'] = role;
    final res = await _apiClient.get('/users', query: query);

    // Tuỳ backend trả List thẳng hay Page object
    final result = res['result'];
    final List<dynamic> list = result is List
        ? result
        : (result as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];

    dev.log('[CUSTOMER/REPO] ✅ Got ${list.length} users (role=$role)');
    return list
        .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CustomerModel> getCustomerDetail(String id) async {
    dev.log('[CUSTOMER/REPO] Fetching customer detail: $id');
    final res = await _apiClient.get('/users/$id');
    final model = CustomerModel.fromJson(res['result'] as Map<String, dynamic>);
    dev.log('[CUSTOMER/REPO] ✅ Customer detail loaded: ${model.email}');
    return model;
  }

  Future<void> deleteCustomer(String id) async {
    dev.log('[CUSTOMER/REPO] Locking customer id=$id');
    await _apiClient.delete('/users/$id');
    dev.log('[CUSTOMER/REPO] ✅ Customer $id locked');
  }

  Future<void> unlockCustomer(String id) async {
    dev.log('[CUSTOMER/REPO] Unlocking customer id=$id');
    await _apiClient.patch('/users/$id/unlock');
    dev.log('[CUSTOMER/REPO] ✅ Customer $id unlocked');
  }
}
