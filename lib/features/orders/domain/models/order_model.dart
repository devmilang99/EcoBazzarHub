import 'package:eco_bazzar_hub/features/cart/domain/models/cart_item.dart';
import 'package:equatable/equatable.dart';

enum OrderStatus { pending, packing, sentToSeller, outForDelivery, delivered, cancelled }

class OrderModel extends Equatable {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final int? rating;
  final String? comment;

  /// The exact moment the order was placed — used for the 10s cancellation window.
  final DateTime placedAt;

  const OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.orderDate,
    this.status = OrderStatus.pending,
    this.cancelledAt,
    this.cancellationReason,
    this.rating,
    this.comment,
    DateTime? placedAt,
  }) : placedAt = placedAt ?? orderDate;

  OrderModel copyWith({
    String? id,
    List<CartItem>? items,
    double? totalAmount,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    DateTime? orderDate,
    OrderStatus? status,
    DateTime? cancelledAt,
    String? cancellationReason,
    int? rating,
    String? comment,
    DateTime? placedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      placedAt: placedAt ?? this.placedAt,
    );
  }

  /// Seconds remaining in the cancellation window (0 when expired).
  int get cancelSecondsLeft {
    final elapsed = DateTime.now().difference(placedAt).inSeconds;
    final remaining = 10 - elapsed;
    return remaining < 0 ? 0 : remaining;
  }

  bool get canCancel => status == OrderStatus.pending && cancelSecondsLeft > 0;

  @override
  List<Object?> get props => [
        id,
        items,
        totalAmount,
        subtotal,
        taxAmount,
        discountAmount,
        orderDate,
        status,
        cancelledAt,
        cancellationReason,
        rating,
        comment,
        placedAt,
      ];
}
