import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../domain/models/order_model.dart';
import '../../../cart/domain/models/cart_item.dart';
import '../../../home/domain/models/product_model.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers.dart';

class OrderNotifier extends StateNotifier<List<OrderModel>> {
  final AppDatabase _db;

  OrderNotifier(this._db) : super([]) {
    _loadOrders();
  }

  final Map<String, Timer> _tickTimers = {};

  /// Loads orders from the Drift database and resumes any active status timers.
  Future<void> _loadOrders() async {
    final dbOrders = await _db.select(_db.orders).get();
    final List<OrderModel> loadedOrders = [];

    for (var dbOrder in dbOrders) {
      // Fetch items for this order
      final dbItems = await (_db.select(
        _db.orderItemsTable,
      )..where((t) => t.orderId.equals(dbOrder.id))).get();

      final items = dbItems
          .map(
            (item) => CartItem(
              product: ProductModel(
                id: item.productId,
                name: item.productName,
                price: item.productPrice,
                imageUrl: item.productImageUrl,
                description: 'Premium quality product.',
                category: 'General',
                categoryId: 'all',
              ),
              quantity: item.quantity,
              sellerName: 'Eco Store',
            ),
          )
          .toList();

      final order = OrderModel(
        id: dbOrder.id,
        items: items,
        totalAmount: dbOrder.totalAmount,
        subtotal: dbOrder.subtotal,
        taxAmount: dbOrder.taxAmount,
        discountAmount: dbOrder.discountAmount,
        orderDate: dbOrder.orderDate,
        status: OrderStatus.values[dbOrder.status],
        cancelledAt: dbOrder.cancelledAt,
        cancellationReason: dbOrder.cancellationReason,
        rating: dbOrder.rating,
        comment: dbOrder.comment,
        placedAt: dbOrder.placedAt,
        pausedAt: null,
        pausedSeconds: 0,
      );

      loadedOrders.add(order);

      // Resume tracking timer if order is still in progress
      if (order.status != OrderStatus.delivered &&
          order.status != OrderStatus.cancelled) {
        _startStatusTimer(order);
      }
    }

    // Sort by date descending (latest first)
    state = loadedOrders..sort((a, b) => b.orderDate.compareTo(a.orderDate));
  }

  /// Places a new order and persists it to the database atomically.
  Future<void> placeOrder(
    List<CartItem> items,
    double total,
    double subtotal,
    double tax,
    double discount,
  ) async {
    final now = DateTime.now();
    final order = OrderModel(
      id: 'ORD-${now.millisecondsSinceEpoch}',
      items: items,
      totalAmount: total,
      subtotal: subtotal,
      taxAmount: tax,
      discountAmount: discount,
      orderDate: now,
      status: OrderStatus.pending,
      placedAt: now,
      pausedAt: null,
      pausedSeconds: 0,
    );

    state = [order, ...state];

    // Atomically save order and its items to DB
    await _db.saveOrder(
      OrdersCompanion(
        id: Value(order.id),
        totalAmount: Value(order.totalAmount),
        subtotal: Value(order.subtotal),
        taxAmount: Value(order.taxAmount),
        discountAmount: Value(order.discountAmount),
        orderDate: Value(order.orderDate),
        status: Value(order.status.index),
        placedAt: Value(order.placedAt),
      ),
      items
          .map(
            (item) => OrderItemsTableCompanion(
              orderId: Value(order.id),
              productId: Value(item.product.id),
              productName: Value(item.product.name),
              productPrice: Value(item.product.price),
              productImageUrl: Value(item.product.imageUrl),
              quantity: Value(item.quantity),
            ),
          )
          .toList(),
    );

    _startStatusTimer(order);
  }

  void _startStatusTimer(OrderModel initialOrder) {
    _tickTimers[initialOrder.id]?.cancel();
    _tickTimers[initialOrder.id] = Timer.periodic(const Duration(seconds: 1), (
      t,
    ) async {
      if (!mounted) {
        t.cancel();
        return;
      }

      // Find current state of this order
      final currentOrder = state.firstWhere((o) => o.id == initialOrder.id);
      if (currentOrder.status == OrderStatus.cancelled ||
          currentOrder.status == OrderStatus.delivered) {
        t.cancel();
        return;
      }

      if (currentOrder.isPaused) {
        state = [...state];
        return;
      }

      final elapsed = currentOrder.elapsedSeconds;

      // Advance status based on elapsed time.
      // The 10s cancellation window is the first phase; delivery phases begin at 10s.
      // Full cycle: pending(0-10s) → packing(10-25s) → sentToSeller(25-37s)
      //             → outForDelivery(37-50s) → delivered(50s+)
      OrderStatus newStatus = currentOrder.status;
      if (elapsed >= 50) {
        newStatus = OrderStatus.delivered;
        t.cancel();
      } else if (elapsed >= 37) {
        newStatus = OrderStatus.outForDelivery;
      } else if (elapsed >= 25) {
        newStatus = OrderStatus.sentToSeller;
      } else if (elapsed >= 10) {
        // Transition to packing the exact moment the cancellation window expires.
        newStatus = OrderStatus.packing;
      }

      if (newStatus != currentOrder.status) {
        await _db.updateOrderStatus(currentOrder.id, newStatus.index);
        state = state.map((o) {
          if (o.id == currentOrder.id) return o.copyWith(status: newStatus);
          return o;
        }).toList();
      } else {
        // Force state update to refresh UI animations (pulsing badges, countdowns)
        state = [...state];
      }
    });
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    _tickTimers[orderId]?.cancel();
    final now = DateTime.now();

    await _db.updateOrderStatus(
      orderId,
      OrderStatus.cancelled.index,
      cancelledAt: now,
      reason: reason,
    );

    state = state.map((order) {
      if (order.id == orderId && order.canCancel) {
        return order.copyWith(
          status: OrderStatus.cancelled,
          cancelledAt: now,
          cancellationReason: reason,
          clearPausedAt: true,
        );
      }
      return order;
    }).toList();
  }

  void pauseOrder(String orderId) {
    state = state.map((order) {
      if (order.id == orderId &&
          !order.isPaused &&
          order.status == OrderStatus.pending) {
        return order.copyWith(pausedAt: DateTime.now());
      }
      return order;
    }).toList();
  }

  void resumeOrder(String orderId) {
    state = state.map((order) {
      if (order.id == orderId && order.isPaused) {
        final now = DateTime.now();
        final currentPaused = now.difference(order.pausedAt!).inSeconds;
        return order.copyWith(
          clearPausedAt: true,
          pausedSeconds: order.pausedSeconds + currentPaused,
        );
      }
      return order;
    }).toList();
  }

  Future<void> updateOrderFeedback(
    String orderId,
    int rating,
    String comment,
  ) async {
    await _db.updateOrderFeedback(orderId, rating, comment);
    state = state.map((order) {
      if (order.id == orderId) {
        return order.copyWith(rating: rating, comment: comment);
      }
      return order;
    }).toList();
  }

  Future<void> deleteOrder(String orderId) async {
    await _db.deleteOrder(orderId);
    state = state.where((order) => order.id != orderId).toList();
  }

  Future<void> deleteAllCompletedOrders() async {
    await _db.deleteOrdersByStatus(OrderStatus.delivered.index);
    state = state.where((order) => order.status != OrderStatus.delivered).toList();
  }

  @override
  void dispose() {
    for (final t in _tickTimers.values) {
      t.cancel();
    }
    super.dispose();
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<OrderModel>>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  return OrderNotifier(db);
});
