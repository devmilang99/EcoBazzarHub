import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cart_item.dart';
import '../../../home/domain/models/product_model.dart';

class CartState {
  final List<CartItem> items;
  final String? voucher;
  final double taxRate;
  final String paymentMethod;

  CartState({
    this.items = const [],
    this.voucher,
    this.taxRate = 0.05, // 5% default tax
    this.paymentMethod = 'Cash on Delivery',
  });

  double get subtotal => items
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + item.totalPrice);

  double get taxAmount => subtotal * taxRate;

  double get discountAmount {
    if (voucher == 'WELCOME10') return subtotal * 0.10;
    if (voucher == 'ECO20') return subtotal * 0.20;
    return 0;
  }

  double get total => subtotal + taxAmount - discountAmount;

  CartState copyWith({
    List<CartItem>? items,
    String? voucher,
    double? taxRate,
    String? paymentMethod,
    bool clearVoucher = false,
  }) {
    return CartState(
      items: items ?? this.items,
      voucher: clearVoucher ? null : (voucher ?? this.voucher),
      taxRate: taxRate ?? this.taxRate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addToCart(ProductModel product) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(product: product),
        ],
      );
    }
  }

  void removeFromCart(String productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.product.id == productId) {
          return item.copyWith(quantity: quantity);
        }
        return item;
      }).toList(),
    );
  }

  void toggleSelection(String productId) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.product.id == productId) {
          return item.copyWith(isSelected: !item.isSelected);
        }
        return item;
      }).toList(),
    );
  }

  void toggleAll(bool isSelected) {
    state = state.copyWith(
      items: state.items.map((item) => item.copyWith(isSelected: isSelected)).toList(),
    );
  }

  void applyVoucher(String? voucherCode) {
    state = state.copyWith(
      voucher: voucherCode,
      clearVoucher: voucherCode == null,
    );
  }

  void updatePaymentMethod(String paymentMethod) {
    state = state.copyWith(paymentMethod: paymentMethod);
  }

  void clearCart() {
    state = state.copyWith(items: []);
  }

  void clearSelectedItems() {
    state = state.copyWith(
      items: state.items.where((item) => !item.isSelected).toList(),
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
