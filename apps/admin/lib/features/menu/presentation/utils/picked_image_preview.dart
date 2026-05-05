import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Nén ảnh chọn/cắt về JPEG tạm (giảm RAM khi preview & upload).
Future<File?> compressPickedImageToTempJpeg(File source) async {
  final dir = await getTemporaryDirectory();
  final outPath =
      '${dir.path}/menu_preview_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final out = await FlutterImageCompress.compressAndGetFile(
    source.absolute.path,
    outPath,
    quality: 85,
    minWidth: 1200,
    minHeight: 1200,
  );
  if (out == null) return null;
  return File(out.path);
}
