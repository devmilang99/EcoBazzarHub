import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/order_model.dart';
import '../../../cart/domain/models/cart_item.dart';

class OrderNotifier extends StateNotifier<List<OrderModel>> {
  OrderNotifier() : super([]);

  void placeOrder(List<CartItem> items, double total) {
    final order = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      totalAmount: total,
      orderDate: DateTime.now(),
    );
    state = [order, ...state];
    
    // Refresh the state after 20 seconds to update the "canCancel" status UI
    Timer(const Duration(seconds: 20), () {
      state = [...state]; 
    });
  }

  void cancelOrder(String orderId) {
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
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<OrderModel>>((ref) {
  return OrderNotifier();
});
