import 'package:eco_bazzar_hub/features/home/domain/models/product_model.dart';
import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final ProductModel product;
  final int quantity;
  final bool isSelected;
  final String sellerName;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.isSelected = true,
    this.sellerName = 'Eco Store',
  });

  CartItem copyWith({
    ProductModel? product,
    int? quantity,
    bool? isSelected,
    String? sellerName,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      sellerName: sellerName ?? this.sellerName,
    );
  }

  double get totalPrice => product.price * quantity;

  @override
  List<Object?> get props => [product, quantity, isSelected, sellerName];
}
