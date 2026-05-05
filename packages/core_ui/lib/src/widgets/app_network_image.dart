import 'dart:math' show max;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  // Override tự động tính theo width/height * devicePixelRatio.
  final int? memCacheWidth;
  final int? memCacheHeight;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final double pixelRatio = MediaQuery.devicePixelRatioOf(context);
    // memCache* là pixel decode; nhiều call site truyền nhầm bằng kích thước logic → ảnh mờ.
    // Luôn đảm bảo decode ít nhất bằng (layout * devicePixelRatio).
    final int? resolvedCacheWidth = _resolveCacheExtent(
      width,
      memCacheWidth,
      pixelRatio,
    );
    final int? resolvedCacheHeight = _resolveCacheExtent(
      height,
      memCacheHeight,
      pixelRatio,
    );

    final image = _buildImage(resolvedCacheWidth, resolvedCacheHeight);
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  /// Decode đủ pixel cho vùng hiển thị; [explicit] có thể là max thêm (ví dụ giới hạn RAM).
  static int? _resolveCacheExtent(
    double? layoutExtent,
    int? explicit,
    double devicePixelRatio,
  ) {
    final needed = layoutExtent != null &&
            layoutExtent.isFinite &&
            layoutExtent > 0
        ? (layoutExtent * devicePixelRatio).ceil()
        : null;
    if (explicit == null) return needed;
    if (needed == null) return explicit;
    return max(explicit, needed);
  }

  Widget _buildImage(int? cacheWidth, int? cacheHeight) {
    if (url == null || url!.isEmpty) return _defaultError();

    return CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.medium,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      placeholder: (_, __) => placeholder ?? _defaultPlaceholder(),
      errorWidget: (_, __, ___) => errorWidget ?? _defaultError(),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.grey100,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryOrange,
        ),
      ),
    );
  }

  Widget _defaultError() {
    return Container(
      width: width,
      height: height,
      color: AppColors.grey100,
      child: const Center(
        child: Icon(Icons.restaurant, color: AppColors.grey400, size: 36),
      ),
    );
  }
}
