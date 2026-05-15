import 'package:eco_bazzar_hub/features/cart/domain/models/cart_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../home/domain/models/product_model.dart';
import '../../../../core/providers.dart';
import '../../../../core/database/app_database.dart';

class CartState {
  final List<CartItem> items;
  final String? voucher;
  final double taxRate;
  final String paymentMethod;
  final bool isLoading;

  CartState({
    this.items = const [],
    this.voucher,
    this.taxRate = 0.05, // 5% default tax
    this.paymentMethod = 'Cash on Delivery',
    this.isLoading = false,
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
    bool? isLoading,
    bool clearVoucher = false,
  }) {
    return CartState(
      items: items ?? this.items,
      voucher: clearVoucher ? null : (voucher ?? this.voucher),
      taxRate: taxRate ?? this.taxRate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final AppDatabase _db;

  CartNotifier(this._db) : super(CartState(isLoading: true)) {
    _loadCart();
  }

  /// Loads cart items from the Drift database on initialization.
  Future<void> _loadCart() async {
    final dbItems = await _db.select(_db.cartItems).get();
    final items = dbItems.map((row) {
      return CartItem(
        product: ProductModel(
          id: row.productId,
          name: row.productName,
          price: row.productPrice,
          description: row.description,
          imageUrl: row.productImageUrl,
          category: row.category,
          categoryId: row.categoryId,
        ),
        quantity: row.quantity,
        isSelected: row.isSelected,
        sellerName: row.sellerName,
      );
    }).toList();
    state = state.copyWith(items: items, isLoading: false);
  }

  /// Synchronizes a domain CartItem with the Drift database atomically.
  Future<void> _syncToDb(CartItem item) async {
    await _db.syncCartItem(
      CartItemsCompanion(
        productId: Value(item.product.id),
        productName: Value(item.product.name),
        productPrice: Value(item.product.price),
        productImageUrl: Value(item.product.imageUrl),
        quantity: Value(item.quantity),
        isSelected: Value(item.isSelected),
        sellerName: Value(item.sellerName),
      ),
    );
  }

  Future<void> addToCart(ProductModel product) async {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );
    CartItem newItem;
    if (existingIndex >= 0) {
      newItem = state.items[existingIndex].copyWith(
        quantity: state.items[existingIndex].quantity + 1,
      );
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = newItem;
      state = state.copyWith(items: updatedItems);
    } else {
      newItem = CartItem(product: product);
      state = state.copyWith(items: [...state.items, newItem]);
    }
    await _syncToDb(newItem);
  }

  Future<void> removeFromCart(String productId) async {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
    await (_db.delete(
      _db.cartItems,
    )..where((t) => t.productId.equals(productId))).go();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }
    CartItem? updatedItem;
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.product.id == productId) {
          updatedItem = item.copyWith(quantity: quantity);
          return updatedItem!;
        }
        return item;
      }).toList(),
    );
    if (updatedItem != null) await _syncToDb(updatedItem!);
  }

  Future<void> toggleSelection(String productId) async {
    CartItem? updatedItem;
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.product.id == productId) {
          updatedItem = item.copyWith(isSelected: !item.isSelected);
          return updatedItem!;
        }
        return item;
      }).toList(),
    );
    if (updatedItem != null) await _syncToDb(updatedItem!);
  }

  Future<void> toggleAll(bool isSelected) async {
    state = state.copyWith(
      items: state.items
          .map((item) => item.copyWith(isSelected: isSelected))
          .toList(),
    );
    // Atomic update for all items in DB
    await _db.transaction(() async {
      for (final item in state.items) {
        await _syncToDb(item);
      }
    });
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

  Future<void> clearCart() async {
    state = state.copyWith(items: []);
    await _db.clearCart();
  }

  Future<void> clearSelectedItems() async {
    final selectedIds = state.items
        .where((item) => item.isSelected)
        .map((e) => e.product.id)
        .toList();
    state = state.copyWith(
      items: state.items.where((item) => !item.isSelected).toList(),
    );
    await (_db.delete(
      _db.cartItems,
    )..where((t) => t.productId.isIn(selectedIds))).go();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final db = ref.watch(databaseProvider);
  return CartNotifier(db);
});
