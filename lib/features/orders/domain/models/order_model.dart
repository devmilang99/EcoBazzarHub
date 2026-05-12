import 'package:eco_bazzar_hub/features/cart/domain/models/cart_item.dart';
import 'package:equatable/equatable.dart';

enum OrderStatus { pending, packing, sentToSeller, outForDelivery, delivered, cancelled }

class OrderModel extends Equatable {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final DateTime? cancelledAt;
  /// The exact moment the order was placed — used for the 20s cancellation window.
  final DateTime placedAt;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = OrderStatus.pending,
    this.cancelledAt,
    DateTime? placedAt,
  }) : placedAt = placedAt ?? orderDate;

  OrderModel copyWith({
    String? id,
    List<CartItem>? items,
    double? totalAmount,
    DateTime? orderDate,
    OrderStatus? status,
    DateTime? cancelledAt,
    DateTime? placedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      placedAt: placedAt ?? this.placedAt,
    );
  }

  /// Seconds remaining in the cancellation window (0 when expired).
  int get cancelSecondsLeft {
    final elapsed = DateTime.now().difference(placedAt).inSeconds;
    final remaining = 20 - elapsed;
    return remaining < 0 ? 0 : remaining;
  }

  bool get canCancel =>
      status == OrderStatus.pending && cancelSecondsLeft > 0;

  @override
  List<Object?> get props => [id, items, totalAmount, orderDate, status, cancelledAt, placedAt];
}
