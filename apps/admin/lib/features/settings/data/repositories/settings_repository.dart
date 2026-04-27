import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/settings_models.dart';

class SettingsRepository {
  SettingsRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<List<BannerModel>> fetchBanners() async {
    final res = await _apiClient.get('/settings/banners');
    final list = res['result'] as List<dynamic>? ?? [];
    dev.log('[SETTINGS/REPO] ✅ Loaded ${list.length} banners');
    return list
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BannerModel> createBanner({
    required String title,
    required List<int> imageBytes,
    required String filename,
    String? linkUrl,
  }) async {
    dev.log('[SETTINGS/REPO] Creating banner: $title');
    final fields = <String, String>{'title': title};
    if (linkUrl != null && linkUrl.isNotEmpty) fields['linkUrl'] = linkUrl;
    final res = await _apiClient.multipartPost(
      '/settings/banners',
      fields: fields,
      files: [
        (
          field: 'file',
          bytes: imageBytes,
          filename: filename,
          contentType: 'image/jpeg',
        )
      ],
    );
    final created =
        BannerModel.fromJson(res['result'] as Map<String, dynamic>);
    dev.log('[SETTINGS/REPO] ✅ Banner created: id=${created.id}');
    return created;
  }

  Future<void> deleteBanner(int id) async {
    dev.log('[SETTINGS/REPO] Deleting banner: $id');
    await _apiClient.delete('/settings/banners/$id');
    dev.log('[SETTINGS/REPO] ✅ Banner $id deleted');
  }

  Future<StoreSettingModel> fetchStoreSetting() async {
    final res = await _apiClient.get('/settings/store');
    dev.log('[SETTINGS/REPO] ✅ Store setting loaded');
    return StoreSettingModel.fromJson(res['result'] as Map<String, dynamic>);
  }

  Future<void> updateStoreSetting(StoreSettingModel model) async {
    dev.log('[SETTINGS/REPO] Updating store setting: isOpen=${model.isOpen}');
    await _apiClient.put('/settings/store', body: model.toJson());
    dev.log('[SETTINGS/REPO] ✅ Store setting updated');
  }
}
