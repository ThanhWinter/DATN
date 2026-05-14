import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:core_ui/core_ui.dart';
import 'package:get/get.dart';

import '../../../main/presentation/controllers/main_controller.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderController extends GetxController {
  OrderController(this._repository);

  final OrderRepository _repository;

  final isLoading = true.obs;
  final error = Rxn<String>();
  final isUpdating = false.obs;

  // 'all' | 'pending' | 'active' | 'completed' | 'cancelled'
  final selectedFilter = 'all'.obs;

  // Null = không có tab nào đang lazy-load; có giá trị = index tab đang tải.
  final loadingTabIndex = Rxn<int>();

  /// Giữ nguyên tên — bind UI TabBarView (không đổi).
  final pendingOrders = <OrderModel>[].obs;
  final activeOrders = <OrderModel>[].obs;
  final completedOrders = <OrderModel>[].obs;
  final cancelledOrders = <OrderModel>[].obs;

  int get pendingCount => pendingOrders.length;
  int get activeCount => activeOrders.length;

  static const int _pageSize = 24;
  static const int _pollPageSize = 40;
  static const int _maxOrdersPerBucket = 220;

  int _pendingLoadedPage = -1;
  bool _pendingHasMore = true;

  int _activeLoadedPage = -1;
  bool _activeHasMore = true;

  int _completedLoadedPage = -1;
  bool _completedHasMore = true;

  int _cancelledLoadedPage = -1;
  bool _cancelledHasMore = true;

  bool _loadMoreBusy = false;
  DateTime? _lastLoadMoreAt;

  // Theo dõi tab nào đã được fetch ít nhất một lần.
  final _tabLoaded = <bool>[false, false, false, false];

  /// orderId → bucket hiện tại — cho phép _removeOrderById chạy O(1).
  final _bucketOf = <String, RxList<OrderModel>>{};

  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        _pollRecentChanges();
      },
    );
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  /// Tải lần đầu / kéo refresh — nạp Tab 0 (Pending) và Tab 1 (Active) đồng thời.
  Future<void> loadOrders() async {
    dev.log('[ORDER/VM] Loading orders — eager: tab 0 + tab 1...');
    isLoading.value = true;
    error.value = null;
    try {
      _resetBucketsAndPaging();
      await Future.wait([
        _loadPendingBucket(),
        _loadActiveBucket(),
      ]);
      _tabLoaded[0] = true;
      _tabLoaded[1] = true;
      dev.log('[ORDER/VM] ✅ Tab 0 (Pending) + Tab 1 (Active) loaded');
      if (Get.isRegistered<MainController>()) {
        await Get.find<MainController>().refreshPendingBadgeFromNetwork();
      }
    } catch (e) {
      dev.log('[ORDER/VM] ❌ loadOrders error: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  bool isTabLoaded(int index) => _tabLoaded[index];

  /// Load thêm dữ liệu phân trang cho filter đang chọn.
  Future<void> loadMoreForFilter(String filter) async {
    switch (filter) {
      case 'pending':
        await loadMoreForTab(0);
      case 'active':
        await loadMoreForTab(1);
      case 'completed':
        await loadMoreForTab(2);
      case 'cancelled':
        await loadMoreForTab(3);
      default: // 'all'
        if (_pendingHasMore) {
          await loadMoreForTab(0);
        } else {
          await loadMoreForTab(1);
        }
    }
  }

  /// Gọi khi người dùng chuyển sang tab [tabIndex].
  /// Fetch dữ liệu bucket tương ứng nếu chưa được tải lần nào.
  Future<void> loadTabOnDemand(int tabIndex) async {
    if (tabIndex < 0 || tabIndex > 3) return;
    if (_tabLoaded[tabIndex]) return;
    if (loadingTabIndex.value == tabIndex) return;

    dev.log('[ORDER/VM] On-demand load: tab $tabIndex');
    loadingTabIndex.value = tabIndex;
    try {
      switch (tabIndex) {
        case 1:
          await _loadActiveBucket();
          break;
        case 2:
          await _loadCompletedBucket();
          break;
        case 3:
          await _loadCancelledBucket();
          break;
        default:
          return;
      }
      _tabLoaded[tabIndex] = true;
      dev.log('[ORDER/VM] ✅ Tab $tabIndex loaded on demand');
    } catch (e) {
      dev.log('[ORDER/VM] ❌ loadTabOnDemand tab $tabIndex: $e');
    } finally {
      loadingTabIndex.value = null;
    }
  }

  /// Lazy load khi cuộn gần cuối danh sách theo tab (0..3).
  Future<void> loadMoreForTab(int tabIndex) async {
    if (_loadMoreBusy) return;
    final now = DateTime.now();
    if (_lastLoadMoreAt != null &&
        now.difference(_lastLoadMoreAt!) < const Duration(milliseconds: 400)) {
      return;
    }

    switch (tabIndex) {
      case 0:
        if (!_pendingHasMore) return;
        break;
      case 1:
        if (!_activeHasMore) return;
        break;
      case 2:
        if (!_completedHasMore) return;
        break;
      case 3:
        if (!_cancelledHasMore) return;
        break;
      default:
        return;
    }

    _loadMoreBusy = true;
    _lastLoadMoreAt = now;
    try {
      switch (tabIndex) {
        case 0:
          await _loadMorePending();
          break;
        case 1:
          await _loadMoreActive();
          break;
        case 2:
          await _loadMoreCompleted();
          break;
        case 3:
          await _loadMoreCancelled();
          break;
      }
    } catch (e) {
      dev.log('[ORDER/VM] loadMore tab $tabIndex: $e');
    } finally {
      _loadMoreBusy = false;
    }
  }

  // ── Polling: chỉ trang đầu "gần đây", merge vào bucket — không full reload ──

  Future<void> _pollRecentChanges() async {
    if (isLoading.value) return;
    try {
      final page = await _repository.fetchOrdersPage(
        page: 0,
        size: _pollPageSize,
      );
      // Batch: upsert tất cả trước, track bucket nào bị dirty
      final dirtyBuckets = <RxList<OrderModel>>{};
      for (final o in page.items) {
        final oldBucket = _bucketOf.remove(o.id);
        oldBucket?.removeWhere((x) => x.id == o.id);
        if (oldBucket != null) {
          dirtyBuckets.add(oldBucket);
        }
        final newBucket = _rxTargetForStatus(o.status);
        newBucket.add(o);
        _bucketOf[o.id] = newBucket;
        dirtyBuckets.add(newBucket);
      }
      // Sort mỗi bucket dirty đúng một lần thay vì N lần
      for (final bucket in dirtyBuckets) {
        _sortBucket(bucket);
      }
      _trimAllBuckets();
      dev.log('[ORDER/VM] 🔁 Poll merged ${page.items.length} recent orders');
      if (Get.isRegistered<MainController>()) {
        unawaited(Get.find<MainController>().refreshPendingBadgeFromNetwork());
      }
    } catch (e) {
      dev.log('[ORDER/VM] Poll skipped: $e');
    }
  }

  void _resetBucketsAndPaging() {
    pendingOrders.clear();
    activeOrders.clear();
    completedOrders.clear();
    cancelledOrders.clear();
    _bucketOf.clear();

    _pendingLoadedPage = -1;
    _pendingHasMore = true;
    _activeLoadedPage = -1;
    _activeHasMore = true;
    _completedLoadedPage = -1;
    _completedHasMore = true;
    _cancelledLoadedPage = -1;
    _cancelledHasMore = true;

    _tabLoaded[0] = false;
    _tabLoaded[1] = false;
    _tabLoaded[2] = false;
    _tabLoaded[3] = false;
  }

  int _halfSplit() => math.max(8, _pageSize ~/ 2);

  Future<void> _loadPendingBucket() async {
    final half = _halfSplit();
    final r1 = await _repository.fetchOrdersPage(
      status: OrderModel.statusPending,
      page: 0,
      size: half,
    );
    final r2 = await _repository.fetchOrdersPage(
      status: OrderModel.statusPaid,
      page: 0,
      size: half,
    );
    final merged = _mergeByDateDesc([...r1.items, ...r2.items]);
    pendingOrders.assignAll(merged);
    for (final o in merged) {
      _bucketOf[o.id] = pendingOrders;
    }
    _pendingLoadedPage = 0;
    _pendingHasMore = !(r1.last && r2.last);
  }

  Future<void> _loadMorePending() async {
    if (!_pendingHasMore) return;
    final next = _pendingLoadedPage + 1;
    final half = _halfSplit();
    final r1 = await _repository.fetchOrdersPage(
      status: OrderModel.statusPending,
      page: next,
      size: half,
    );
    final r2 = await _repository.fetchOrdersPage(
      status: OrderModel.statusPaid,
      page: next,
      size: half,
    );
    if (r1.items.isEmpty && r2.items.isEmpty) {
      _pendingHasMore = false;
      return;
    }
    _appendDedupeSort(pendingOrders, [...r1.items, ...r2.items]);
    _pendingLoadedPage = next;
    _pendingHasMore = !(r1.last && r2.last);
  }

  Future<void> _loadActiveBucket() async {
    final half = _halfSplit();
    final r1 = await _repository.fetchOrdersPage(
      status: OrderModel.statusPreparing,
      page: 0,
      size: half,
    );
    final r2 = await _repository.fetchOrdersPage(
      status: OrderModel.statusDelivering,
      page: 0,
      size: half,
    );
    final merged = _mergeByDateDesc([...r1.items, ...r2.items]);
    activeOrders.assignAll(merged);
    for (final o in merged) {
      _bucketOf[o.id] = activeOrders;
    }
    _activeLoadedPage = 0;
    _activeHasMore = !(r1.last && r2.last);
  }

  Future<void> _loadMoreActive() async {
    if (!_activeHasMore) return;
    final next = _activeLoadedPage + 1;
    final half = _halfSplit();
    final r1 = await _repository.fetchOrdersPage(
      status: OrderModel.statusPreparing,
      page: next,
      size: half,
    );
    final r2 = await _repository.fetchOrdersPage(
      status: OrderModel.statusDelivering,
      page: next,
      size: half,
    );
    if (r1.items.isEmpty && r2.items.isEmpty) {
      _activeHasMore = false;
      return;
    }
    _appendDedupeSort(activeOrders, [...r1.items, ...r2.items]);
    _activeLoadedPage = next;
    _activeHasMore = !(r1.last && r2.last);
  }

  Future<void> _loadCompletedBucket() async {
    final r = await _repository.fetchOrdersPage(
      status: OrderModel.statusCompleted,
      page: 0,
      size: _pageSize,
    );
    completedOrders.assignAll(r.items);
    for (final o in r.items) {
      _bucketOf[o.id] = completedOrders;
    }
    _completedLoadedPage = 0;
    _completedHasMore = !r.last;
  }

  Future<void> _loadMoreCompleted() async {
    if (!_completedHasMore) return;
    final next = _completedLoadedPage + 1;
    final r = await _repository.fetchOrdersPage(
      status: OrderModel.statusCompleted,
      page: next,
      size: _pageSize,
    );
    if (r.items.isEmpty) {
      _completedHasMore = false;
      return;
    }
    _appendDedupeSort(completedOrders, r.items);
    _completedLoadedPage = next;
    _completedHasMore = !r.last;
  }

  Future<void> _loadCancelledBucket() async {
    final r = await _repository.fetchOrdersPage(
      status: OrderModel.statusCancelled,
      page: 0,
      size: _pageSize,
    );
    cancelledOrders.assignAll(r.items);
    for (final o in r.items) {
      _bucketOf[o.id] = cancelledOrders;
    }
    _cancelledLoadedPage = 0;
    _cancelledHasMore = !r.last;
  }

  Future<void> _loadMoreCancelled() async {
    if (!_cancelledHasMore) return;
    final next = _cancelledLoadedPage + 1;
    final r = await _repository.fetchOrdersPage(
      status: OrderModel.statusCancelled,
      page: next,
      size: _pageSize,
    );
    if (r.items.isEmpty) {
      _cancelledHasMore = false;
      return;
    }
    _appendDedupeSort(cancelledOrders, r.items);
    _cancelledLoadedPage = next;
    _cancelledHasMore = !r.last;
  }

  List<OrderModel> _mergeByDateDesc(List<OrderModel> raw) {
    final out = [...raw];
    out.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return out;
  }

  void _appendDedupeSort(RxList<OrderModel> target, List<OrderModel> incoming) {
    final existing = {for (final o in target) o.id};
    for (final o in incoming) {
      if (existing.add(o.id)) {
        target.add(o);
        _bucketOf[o.id] = target;
      }
    }
    final sorted = [...target]
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    target.assignAll(sorted);
  }

  RxList<OrderModel> _rxTargetForStatus(String status) {
    if (status == OrderModel.statusPending || status == OrderModel.statusPaid) {
      return pendingOrders;
    }
    if (status == OrderModel.statusPreparing ||
        status == OrderModel.statusDelivering) {
      return activeOrders;
    }
    if (status == OrderModel.statusCompleted) return completedOrders;
    if (status == OrderModel.statusCancelled) return cancelledOrders;
    return pendingOrders;
  }

  void _sortBucket(RxList<OrderModel> list) {
    final sorted = [...list]
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    list.assignAll(sorted);
  }

  void _trimAllBuckets() {
    _trimBucket(pendingOrders);
    _trimBucket(activeOrders);
    _trimBucket(completedOrders);
    _trimBucket(cancelledOrders);
  }

  void _trimBucket(RxList<OrderModel> list) {
    if (list.length <= _maxOrdersPerBucket) return;
    final sorted = [...list]
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    final kept = sorted.take(_maxOrdersPerBucket).toList();
    final keptIds = {for (final o in kept) o.id};
    for (final o in list) {
      if (!keptIds.contains(o.id)) {
        _bucketOf.remove(o.id);
      }
    }
    list.assignAll(kept);
  }

  Future<void> updateStatus(OrderModel order, String newStatus) async {
    dev.log(
        '[ORDER/VM] Updating order ${order.id}: ${order.status} → $newStatus');
    isUpdating.value = true;
    try {
      await _repository.updateOrderStatus(order.id, newStatus);

      // Tìm object đang nằm trong bucket (có thể là object mới hơn do polling thay thế).
      // Không dùng _distribute() vì polling có thể đã thay thế reference 'order'.
      final currentBucket = _bucketOf[order.id];
      final inBucket = currentBucket?.firstWhereOrNull((o) => o.id == order.id);
      final target = inBucket ?? order;
      target.status = newStatus;

      final newBucket = _rxTargetForStatus(newStatus);

      if (currentBucket == newBucket) {
        // Order đã ở đúng bucket (poll đã move trước) — chỉ cần sort lại, không xóa+thêm.
        _sortBucket(newBucket);
      } else {
        // Xoá khỏi bucket cũ, thêm vào bucket mới.
        _bucketOf.remove(order.id);
        currentBucket?.removeWhere((o) => o.id == order.id);
        if (!newBucket.any((o) => o.id == order.id)) {
          newBucket.add(target);
        }
        _bucketOf[order.id] = newBucket;
        _sortBucket(newBucket);
      }

      if (Get.isRegistered<MainController>()) {
        unawaited(Get.find<MainController>().refreshPendingBadgeFromNetwork());
      }
      Get.snackbar(
        'Cập nhật thành công',
        'Đơn #${order.id.substring(0, 8).toUpperCase()} → ${OrderModel.statusLabel(newStatus)}',
        backgroundColor: AppColors.successGreen,
        colorText: AppColors.white,
      );
      dev.log('[ORDER/VM] ✅ Order ${order.id} status updated to $newStatus');
    } catch (e) {
      dev.log('[ORDER/VM] ❌ updateStatus error: $e');
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật đơn hàng: $e',
        backgroundColor: AppColors.errorRed,
        colorText: AppColors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }
}
