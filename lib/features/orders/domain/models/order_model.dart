import 'package:eco_bazzar_hub/features/cart/domain/models/cart_item.dart';
import 'package:equatable/equatable.dart';

enum OrderStatus { packing, sentToSeller, outForDelivery, delivered, cancelled }

class OrderModel extends Equatable {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final DateTime? cancelledAt;

  const OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = OrderStatus.packing,
    this.cancelledAt,
  });

  OrderModel copyWith({
    String? id,
    List<CartItem>? items,
    double? totalAmount,
    DateTime? orderDate,
    OrderStatus? status,
    DateTime? cancelledAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  bool get canCancel => 
      status == OrderStatus.packing && 
      DateTime.now().difference(orderDate).inSeconds < 20;

  @override
  List<Object?> get props => [id, items, totalAmount, orderDate, status, cancelledAt];
}
