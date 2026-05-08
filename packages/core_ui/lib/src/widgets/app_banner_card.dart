import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_network_image.dart';

/// Reusable banner card: network image + optional gradient/title overlay +
/// optional arbitrary overlay child (e.g. a status badge).
///
/// Used by both admin (management cards) and customer (promo carousel).
class AppBannerCard extends StatelessWidget {
  const AppBannerCard({
    super.key,
    this.imageUrl,
    this.title,
    this.onTap,
    this.width,
    this.height = 168,
    this.borderRadius = 14.0,
    this.showGradient = false,
    this.overlayChild,
    this.fallbackWidget,
  });

  final String? imageUrl;

  /// When non-null, rendered as white bold text at the bottom of the card,
  /// and the gradient overlay is automatically enabled.
  final String? title;

  final VoidCallback? onTap;
  final double? width;
  final double height;
  final double borderRadius;

  /// Draws a bottom→transparent dark gradient (useful for text legibility).
  /// Automatically true when [title] is provided.
  final bool showGradient;

  /// Arbitrary overlay widget rendered on top of everything, placed directly
  /// inside the [Stack] — wrap in [Positioned] when needed.
  final Widget? overlayChild;

  /// Shown when [imageUrl] is null or fails to load.
  /// Defaults to a plain grey box when omitted.
  final Widget? fallbackWidget;

  @override
  Widget build(BuildContext context) {
    final fallback = fallbackWidget ?? Container(color: AppColors.grey200);
    final hasGradient = showGradient || title != null;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Background image ─────────────────────────────────────────
              if (imageUrl != null)
                AppNetworkImage(
                  url: imageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: fallback,
                )
              else
                fallback,

              // ── Gradient overlay ─────────────────────────────────────────
              if (hasGradient)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 90,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Title text ───────────────────────────────────────────────
              if (title != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Text(
                    title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // ── Caller-supplied overlay (e.g. status badge) ──────────────
              if (overlayChild != null) overlayChild!,
            ],
          ),
        ),
      ),
    );
  }
}
