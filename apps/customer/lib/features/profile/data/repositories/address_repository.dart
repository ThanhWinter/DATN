import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/address_model.dart';

class AddressRepository {
  AddressRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<List<UserAddressModel>> fetchAddresses() async {
    final res = await _apiClient.get('/user/addresses');
    final list = res['result'] as List<dynamic>? ?? [];
    dev.log('[ADDRESS/REPO] ✅ Loaded ${list.length} addresses');
    return list
        .map((e) => UserAddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserAddressModel> createAddress({
    required String fullAddress,
    String? label,
  }) async {
    dev.log('[ADDRESS/REPO] Creating address: $fullAddress');
    final res = await _apiClient.post('/user/addresses', body: {
      'address': fullAddress,
      'title': label ?? '',
      'latitude': 0.0,
      'longitude': 0.0,
    });
    return UserAddressModel.fromJson(res['result'] as Map<String, dynamic>);
  }

  Future<UserAddressModel> updateAddress({
    required int id,
    required String fullAddress,
    String? label,
  }) async {
    dev.log('[ADDRESS/REPO] Updating address: $id');
    final res = await _apiClient.put('/user/addresses/$id', body: {
      'address': fullAddress,
      'title': label ?? '',
      'latitude': 0.0,
      'longitude': 0.0,
    });
    return UserAddressModel.fromJson(res['result'] as Map<String, dynamic>);
  }

  Future<void> deleteAddress(int id) async {
    dev.log('[ADDRESS/REPO] Deleting address: $id');
    await _apiClient.delete('/user/addresses/$id');
    dev.log('[ADDRESS/REPO] ✅ Address $id deleted');
  }

  Future<void> setDefaultAddress(int id) async {
    dev.log('[ADDRESS/REPO] Setting default address: $id');
    await _apiClient.patch('/user/addresses/$id/default');
    dev.log('[ADDRESS/REPO] ✅ Address $id set as default');
  }
}
