import 'dart:developer' as dev;

import 'package:core_network/core_network.dart';

import '../models/settings_models.dart';

class SettingsRepository {
  SettingsRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<List<BannerModel>> fetchBanners() async {
    final res = await _apiClient.get('/settings/banners/all');
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

  Future<BannerModel> updateBanner({
    required int id,
    required String title,
    String? linkUrl,
    List<int>? imageBytes,
    String? filename,
  }) async {
    dev.log('[SETTINGS/REPO] Updating banner: $id');
    final fields = <String, String>{'title': title};
    if (linkUrl != null && linkUrl.isNotEmpty) fields['linkUrl'] = linkUrl;
    final files = imageBytes != null
        ? [
            (
              field: 'file',
              bytes: imageBytes,
              filename: filename ?? 'banner.jpg',
              contentType: 'image/jpeg',
            )
          ]
        : <({String field, List<int> bytes, String filename, String contentType})>[];
    final res = await _apiClient.multipartPut(
      '/settings/banners/$id',
      fields: fields,
      files: files,
    );
    final updated = BannerModel.fromJson(res['result'] as Map<String, dynamic>);
    dev.log('[SETTINGS/REPO] ✅ Banner updated: id=${updated.id}');
    return updated;
  }

  Future<void> toggleBannerStatus(int id, {required bool isActive}) async {
    dev.log('[SETTINGS/REPO] Toggle banner $id → isActive=$isActive');
    await _apiClient
        .patch('/settings/banners/$id/status?isActive=$isActive');
    dev.log('[SETTINGS/REPO] ✅ Banner $id status updated');
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
