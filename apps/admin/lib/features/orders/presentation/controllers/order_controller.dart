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

  /// Giữ nguyên tên — bind UI TabBarView (không đổi).
  final pendingOrders = <OrderModel>[].obs;
  final activeOrders = <OrderModel>[].obs;
  final completedOrders = <OrderModel>[].obs;
  final cancelledOrders = <OrderModel>[].obs;

  int get pendingCount => pendingOrders.length;

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

  /// Tải lần đầu / kéo refresh — reset phân trang và nạp trang đầu mỗi bucket.
  Future<void> loadOrders() async {
    dev.log('[ORDER/VM] Loading orders (paged initial)...');
    isLoading.value = true;
    error.value = null;
    try {
      _resetBucketsAndPaging();
      await Future.wait([
        _loadPendingBucket(),
        _loadActiveBucket(),
        _loadCompletedBucket(),
        _loadCancelledBucket(),
      ]);
      dev.log('[ORDER/VM] ✅ Initial tabs loaded');
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

  // ── Polling: chỉ trang đầu “gần đây”, merge vào bucket — không full reload ──

  Future<void> _pollRecentChanges() async {
    if (isLoading.value) return;
    try {
      final page = await _repository.fetchOrdersPage(
        page: 0,
        size: _pollPageSize,
      );
      for (final o in page.items) {
        _upsertOrderAcrossBuckets(o);
      }
      _trimAllBuckets();
      dev.log('[ORDER/VM] 🔁 Poll merged ${page.items.length} recent orders');
    } catch (e) {
      dev.log('[ORDER/VM] Poll skipped: $e');
    }
  }

  void _resetBucketsAndPaging() {
    pendingOrders.clear();
    activeOrders.clear();
    completedOrders.clear();
    cancelledOrders.clear();

    _pendingLoadedPage = -1;
    _pendingHasMore = true;
    _activeLoadedPage = -1;
    _activeHasMore = true;
    _completedLoadedPage = -1;
    _completedHasMore = true;
    _cancelledLoadedPage = -1;
    _cancelledHasMore = true;
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
    final ids = target.map((e) => e.id).toSet();
    for (final o in incoming) {
      if (!ids.contains(o.id)) {
        target.add(o);
        ids.add(o.id);
      }
    }
    final sorted = [...target]..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    target.assignAll(sorted);
  }

  void _removeOrderById(String id) {
    pendingOrders.removeWhere((o) => o.id == id);
    activeOrders.removeWhere((o) => o.id == id);
    completedOrders.removeWhere((o) => o.id == id);
    cancelledOrders.removeWhere((o) => o.id == id);
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

  void _upsertOrderAcrossBuckets(OrderModel o) {
    _removeOrderById(o.id);
    final bucket = _rxTargetForStatus(o.status);
    bucket.add(o);
    _sortBucket(bucket);
  }

  void _sortBucket(RxList<OrderModel> list) {
    final sorted = [...list]..sort((a, b) => b.orderDate.compareTo(a.orderDate));
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
    final sorted = [...list]..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    list.assignAll(sorted.take(_maxOrdersPerBucket).toList());
  }

  void _distribute(List<OrderModel> all) {
    pendingOrders.assignAll(all
        .where((o) => const [
              OrderModel.statusPending,
              OrderModel.statusPaid,
            ].contains(o.status))
        .toList());

    activeOrders.assignAll(all
        .where((o) => const [
              OrderModel.statusPreparing,
              OrderModel.statusDelivering,
            ].contains(o.status))
        .toList());

    completedOrders.assignAll(
        all.where((o) => o.status == OrderModel.statusCompleted).toList());
    cancelledOrders.assignAll(
        all.where((o) => o.status == OrderModel.statusCancelled).toList());

    for (final bucket in [
      pendingOrders,
      activeOrders,
      completedOrders,
      cancelledOrders,
    ]) {
      _sortBucket(bucket);
    }
  }

  Future<void> updateStatus(OrderModel order, String newStatus) async {
    dev.log(
        '[ORDER/VM] Updating order ${order.id}: ${order.status} → $newStatus');
    isUpdating.value = true;
    try {
      await _repository.updateOrderStatus(order.id, newStatus);
      order.status = newStatus;
      final all = [
        ...pendingOrders,
        ...activeOrders,
        ...completedOrders,
        ...cancelledOrders,
      ];
      _distribute(all);
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
