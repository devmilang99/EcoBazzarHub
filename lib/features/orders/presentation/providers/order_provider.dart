import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/order_model.dart';
import '../../../cart/domain/models/cart_item.dart';

class OrderNotifier extends StateNotifier<List<OrderModel>> {
  OrderNotifier() : super([]);

  final Map<String, Timer> _tickTimers = {};
  final Map<String, Timer> _advanceTimers = {};

  void placeOrder(List<CartItem> items, double total) {
    final now = DateTime.now();
    final order = OrderModel(
      id: 'ORD-${now.millisecondsSinceEpoch}',
      items: items,
      totalAmount: total,
      orderDate: now,
      status: OrderStatus.pending,
      placedAt: now,
    );
    state = [order, ...state];

    // Tick every second so the live countdown updates in UI
    _tickTimers[order.id] = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      // Rebuild state to force UI refresh
      state = [...state];
      if (order.cancelSecondsLeft <= 0) t.cancel();
    });

    // After 20 seconds advance status to packing (if not cancelled)
    _advanceTimers[order.id] = Timer(const Duration(seconds: 20), () {
      if (!mounted) return;
      state = state.map((o) {
        if (o.id == order.id && o.status == OrderStatus.pending) {
          return o.copyWith(status: OrderStatus.packing);
        }
        return o;
      }).toList();
      _tickTimers[order.id]?.cancel();
    });
  }

  void cancelOrder(String orderId) {
    _tickTimers[orderId]?.cancel();
    _advanceTimers[orderId]?.cancel();
    state = state.map((order) {
      if (order.id == orderId && order.canCancel) {
        return order.copyWith(
          status: OrderStatus.cancelled,
          cancelledAt: DateTime.now(),
        );
      }
      return order;
    }).toList();
  }

  @override
  void dispose() {
    for (final t in _tickTimers.values) {
      t.cancel();
    }
    for (final t in _advanceTimers.values) {
      t.cancel();
    }
    super.dispose();
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<OrderModel>>((ref) {
  return OrderNotifier();
});
