import 'dart:async';
import 'dart:developer' as dev;

import 'package:get/get.dart';

import '../../../main/presentation/controllers/main_controller.dart';
import '../../../orders/data/models/coupon_model.dart';
import '../../../payment/data/repositories/coupon_repository.dart';

/// Optimized Coupon List Controller with async improvements and better state management
class OptimizedCouponListController extends GetxController {
  OptimizedCouponListController(this._repository);

  final CouponRepository _repository;

  // Reactive state variables
  final isLoading = false.obs;
  final error = Rxn<String>();
  final searchText = ''.obs;
  final selectedCategory = Rxn<String>();

  // Data lists - updated only when load/refresh to avoid .where().toList() in Obx
  final availableCoupons = <CouponModel>[].obs;
  final expiredCoupons = <CouponModel>[].obs;
  final filteredAvailableCoupons = <CouponModel>[].obs;
  final filteredExpiredCoupons = <CouponModel>[].obs;

  // Computed reactive values
  late final RxInt totalCouponCount;
  late final RxInt availableCount;
  late final RxInt expiredCount;

  bool _isFirstLoad = true;
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    _setupComputedValues();
    _setupSearchListener();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _setupComputedValues() {
    // Computed counts
    totalCouponCount = 0.obs;
    availableCount = 0.obs;
    expiredCount = 0.obs;

    // Update computed values when data changes
    ever(availableCoupons, (_) => _updateComputedValues());
    ever(expiredCoupons, (_) => _updateComputedValues());
    ever(searchText, (_) => _updateFilteredCoupons());
    ever(selectedCategory, (_) => _updateFilteredCoupons());
  }

  void _setupSearchListener() {
    // Debounce search to avoid excessive filtering
    ever(searchText, (_) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _updateFilteredCoupons();
      });
    });
  }

  void _updateComputedValues() {
    final available = availableCoupons.length;
    final expired = expiredCoupons.length;

    totalCouponCount.value = available + expired;
    availableCount.value = available;
    expiredCount.value = expired;

    _updateFilteredCoupons();
  }

  void _updateFilteredCoupons() {
    final query = searchText.value.toLowerCase().trim();
    final category = selectedCategory.value;

    // Filter available coupons
    final filteredAvailable = availableCoupons.where((coupon) {
      final matchesSearch =
          query.isEmpty || coupon.code.toLowerCase().contains(query);

      final matchesCategory = category == null ||
          category == 'all' ||
          _matchesCategory(coupon, category);

      return matchesSearch && matchesCategory;
    }).toList();

    // Filter expired coupons
    final filteredExpired = expiredCoupons.where((coupon) {
      final matchesSearch =
          query.isEmpty || coupon.code.toLowerCase().contains(query);

      final matchesCategory = category == null ||
          category == 'all' ||
          _matchesCategory(coupon, category);

      return matchesSearch && matchesCategory;
    }).toList();

    filteredAvailableCoupons.assignAll(filteredAvailable);
    filteredExpiredCoupons.assignAll(filteredExpired);
  }

  bool _matchesCategory(CouponModel coupon, String category) {
    // Enhanced category matching
    switch (category.toLowerCase()) {
      case 'percentage':
        return coupon.discountType == 'percentage';
      case 'fixed':
        return coupon.discountType == 'fixed';
      case 'free_shipping':
        return coupon.discountType == 'free_shipping';
      case 'expiring_soon':
        final now = DateTime.now();
        final daysUntilExpiry = coupon.expiresAt.difference(now).inDays;
        return daysUntilExpiry > 0 && daysUntilExpiry <= 7;
      default:
        return true;
    }
  }

  /// Load coupons with performance optimization
  Future<void> loadCoupons({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
      error.value = null;
    }

    try {
      final stopwatch = Stopwatch()..start();
      final list = await _repository.fetchAllCoupons();
      stopwatch.stop();

      _partitionCoupons(list);

      // Update main controller badge count
      if (Get.isRegistered<MainController>()) {
        Get.find<MainController>().availableCouponCount.value =
            availableCoupons.length;
      }

      dev.log(
        '[COUPON_LIST] ✅ Loaded ${list.length} coupons in ${stopwatch.elapsedMilliseconds}ms '
        '(${availableCoupons.length} available, ${expiredCoupons.length} expired)',
      );
    } catch (e) {
      error.value = e.toString();
      dev.log('[COUPON_LIST] ❌ loadCoupons error: $e');

      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách mã giảm giá. Vui lòng thử lại.',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  /// Refresh data with pull-to-refresh support
  Future<void> refreshCoupons() async {
    await loadCoupons(showLoading: false);
  }

  /// Ensure first load is called only once
  void ensureFirstLoad() {
    if (!_isFirstLoad) return;
    _isFirstLoad = false;
    loadCoupons();
  }

  /// Partition coupons into available and expired
  void _partitionCoupons(Iterable<CouponModel> source) {
    final now = DateTime.now();
    final av = <CouponModel>[];
    final ex = <CouponModel>[];

    for (final coupon in source) {
      if (coupon.isActive && !coupon.expiresAt.isBefore(now)) {
        av.add(coupon);
      } else {
        ex.add(coupon);
      }
    }

    // Sort by expiration date (soonest expiring first)
    av.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
    ex.sort((a, b) =>
        b.expiresAt.compareTo(a.expiresAt)); // Most recently expired first

    availableCoupons.assignAll(av);
    expiredCoupons.assignAll(ex);
  }

  /// Search functionality
  void searchCoupons(String query) {
    searchText.value = query;
  }

  /// Filter by category
  void filterByCategory(String? category) {
    selectedCategory.value = category;
  }

  /// Clear all filters
  void clearFilters() {
    searchText.value = '';
    selectedCategory.value = null;
  }

  /// Get coupon details with caching
  Future<CouponModel?> getCouponDetails(String code) async {
    try {
      // Check if coupon already exists in our lists
      final existing = [...availableCoupons, ...expiredCoupons]
          .firstWhereOrNull((c) => c.code.toLowerCase() == code.toLowerCase());

      if (existing != null) {
        dev.log('[COUPON_LIST] ✅ Found coupon in cache: $code');
        return existing;
      }

      // Fetch from API if not found locally
      dev.log('[COUPON_LIST] 🔄 Fetching coupon from API: $code');
      return await _repository.getCoupon(code);
    } catch (e) {
      dev.log('[COUPON_LIST] ❌ getCouponDetails error: $e');
      return null;
    }
  }

  /// Batch operations for better performance
  Future<void> preloadPopularCoupons() async {
    if (availableCoupons.isNotEmpty) return;

    try {
      dev.log('[COUPON_LIST] 🚀 Preloading popular coupons...');
      await loadCoupons();
      dev.log('[COUPON_LIST] ✅ Preloading completed');
    } catch (e) {
      dev.log('[COUPON_LIST] ❌ Preloading failed: $e');
    }
  }

  /// Get coupons expiring soon
  List<CouponModel> getExpiringSoonCoupons({int days = 7}) {
    final now = DateTime.now();
    final threshold = now.add(Duration(days: days));

    return availableCoupons.where((coupon) {
      return coupon.expiresAt.isBefore(threshold) &&
          coupon.expiresAt.isAfter(now);
    }).toList();
  }

  /// Get highest value coupons
  List<CouponModel> getHighestValueCoupons({int limit = 5}) {
    final sorted = List<CouponModel>.from(availableCoupons);

    // Sort by discount value (percentage first, then fixed amount)
    sorted.sort((a, b) {
      final aValue = _calculateDiscountValue(a);
      final bValue = _calculateDiscountValue(b);
      return bValue.compareTo(aValue);
    });

    return sorted.take(limit).toList();
  }

  double _calculateDiscountValue(CouponModel coupon) {
    switch (coupon.discountType.toLowerCase()) {
      case 'percentage':
        return coupon.discountValue; // Higher percentage is better
      case 'fixed':
        return coupon.discountValue; // Higher fixed amount is better
      case 'free_shipping':
        return 100.0; // Give high value to free shipping
      default:
        return 0.0;
    }
  }

  /// Performance monitoring
  void logPerformanceMetrics() {
    dev.log('[COUPON_LIST] 📊 Performance Metrics:');
    dev.log('  - Total coupons: ${totalCouponCount.value}');
    dev.log('  - Available: ${availableCount.value}');
    dev.log('  - Expired: ${expiredCount.value}');
    dev.log('  - Filtered available: ${filteredAvailableCoupons.length}');
    dev.log('  - Filtered expired: ${filteredExpiredCoupons.length}');
    dev.log('  - Search query: "${searchText.value}"');
    dev.log('  - Selected category: ${selectedCategory.value}');
  }
}
