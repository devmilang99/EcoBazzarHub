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

    // Master timer to tick every second for UI updates and status progression
    _tickTimers[order.id] = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(order.placedAt).inSeconds;
      
      // Advance status based on elapsed time (mock 50s cycle)
      OrderStatus newStatus = order.status;
      if (elapsed >= 50) {
        newStatus = OrderStatus.delivered;
        t.cancel(); // Stop ticking once delivered
      } else if (elapsed >= 37) {
        newStatus = OrderStatus.outForDelivery;
      } else if (elapsed >= 25) {
        newStatus = OrderStatus.sentToSeller;
      } else if (elapsed >= 12) {
        newStatus = OrderStatus.packing;
      }

      // Update state if status changed or just to force UI refresh (for animations)
      state = state.map((o) {
        if (o.id == order.id) {
          if (o.status == OrderStatus.cancelled) {
            t.cancel();
            return o;
          }
          return o.copyWith(status: newStatus);
        }
        return o;
      }).toList();
    });
  }

  void cancelOrder(String orderId) {
    _tickTimers[orderId]?.cancel();
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
