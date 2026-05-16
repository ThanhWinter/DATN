import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../../data/models/food_model.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    required this.food,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onManageOptions,
    required this.onView,
    super.key,
  });

  final FoodModel food;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManageOptions;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final isAvailable = food.isAvailable;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAvailable
                  ? const Color(0xFFE5E7EB)
                  : const Color(0xFFF0F0F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _FoodThumbnail(food: food, isAvailable: isAvailable),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + status badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              food.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _AvailabilityBadge(isAvailable: isAvailable),
                        ],
                      ),
                      // Description
                      if (food.description?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          food.description!.trim(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                            height: 1.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Price + category
                      Row(
                        children: [
                          Text(
                            '${food.price.toInt().toVnd()}đ',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.emeraldDark,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: _CategoryTag(label: food.categoryName),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Toggle — vertically centred, right edge
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: isAvailable,
                  onChanged: onToggle,
                  activeTrackColor: AppColors.emerald,
                  activeThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFE5E7EB),
                  inactiveThumbColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Thumbnail ────────────────────────────────────────────────────────────────

class _FoodThumbnail extends StatelessWidget {
  const _FoodThumbnail({required this.food, required this.isAvailable});

  final FoodModel food;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(11),
        bottomLeft: Radius.circular(11),
      ),
      child: SizedBox(
        width: 94,
        height: 94,
        child: Stack(
          fit: StackFit.expand,
          children: [
            food.imageUrl != null
                ? AppNetworkImage(
                    url: food.imageUrl!,
                    width: 94,
                    height: 94,
                    fit: BoxFit.cover,
                  )
                : const ColoredBox(
                    color: Color(0xFFF3F4F6),
                    child: Center(
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        color: Color(0xFFD1D5DB),
                        size: 30,
                      ),
                    ),
                  ),
            if (!isAvailable)
              const ColoredBox(
                color: Color(0x70000000),
                child: Center(child: _HiddenBadge()),
              ),
          ],
        ),
      ),
    );
  }
}

class _HiddenBadge extends StatelessWidget {
  const _HiddenBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'ẨN',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Color(0xFF374151),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isAvailable
            ? const Color(0xFFF0FDF4)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAvailable
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        isAvailable ? 'Đang bán' : 'Tạm ẩn',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isAvailable
              ? const Color(0xFF16A34A)
              : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

// ─── Category tag ─────────────────────────────────────────────────────────────

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
