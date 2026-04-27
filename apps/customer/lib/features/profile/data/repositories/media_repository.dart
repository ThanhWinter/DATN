import 'dart:typed_data';

import 'package:core_network/core_network.dart';

class MediaRepository {
  MediaRepository(this._apiClient);

  final IApiClient _apiClient;

  Future<String> uploadImage(Uint8List bytes, String filename) {
    return _apiClient.uploadRaw(
      '/media/upload',
      (field: 'file', bytes: bytes, filename: filename, contentType: 'image/jpeg'),
    );
  }
}
