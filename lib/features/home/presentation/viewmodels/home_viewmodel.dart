import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/product_model.dart';
import '../../domain/models/category_model.dart';

enum ProductSortOption { bestOverall, lowToHigh, highToLow }

class HomeState {
  final List<CategoryModel> categories;
  final List<ProductModel> products;
  final String selectedCategoryId;
  final String searchQuery;
  final ProductSortOption sortOption;
  final bool favoritesOnly;
  final bool isLoading;

  HomeState({
    this.categories = const [],
    this.products = const [],
    this.selectedCategoryId = 'all',
    this.searchQuery = '',
    this.sortOption = ProductSortOption.bestOverall,
    this.favoritesOnly = false,
    this.isLoading = false,
  });

  List<ProductModel> get filteredProducts {
    final filtered = products.where((product) {
      final matchesCategory =
          selectedCategoryId == 'all' ||
          product.categoryId == selectedCategoryId;
      final matchesSearch = product.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchesFavorite = !favoritesOnly || product.isFavorite;
      return matchesCategory && matchesSearch && matchesFavorite;
    }).toList();

    if (sortOption == ProductSortOption.highToLow) {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortOption == ProductSortOption.lowToHigh) {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else {
      filtered.sort(
        (a, b) => (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0),
      );
    }

    return filtered;
  }

  HomeState copyWith({
    List<CategoryModel>? categories,
    List<ProductModel>? products,
    String? selectedCategoryId,
    String? searchQuery,
    ProductSortOption? sortOption,
    bool? favoritesOnly,
    bool? isLoading,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel() : super(HomeState()) {
    _loadMockData();
  }

  void _loadMockData() {
    state = state.copyWith(isLoading: true);

    final categories = [
      const CategoryModel(
        id: 'all',
        name: 'All',
        icon: Icons.grid_view_rounded,
      ),
      const CategoryModel(
        id: 'shoes',
        name: 'Shoes',
        icon: Icons.directions_run_rounded,
      ),
      const CategoryModel(
        id: 'watches',
        name: 'Watches',
        icon: Icons.watch_rounded,
      ),
      const CategoryModel(
        id: 'phones',
        name: 'Phones',
        icon: Icons.smartphone_rounded,
      ),
      const CategoryModel(
        id: 'laptops',
        name: 'Laptops',
        icon: Icons.laptop_mac_rounded,
      ),
      const CategoryModel(
        id: 'audio',
        name: 'Audio',
        icon: Icons.headset_rounded,
      ),
    ];

    final products = [
      const ProductModel(
        id: '1',
        name: 'Nike Air Max 2024',
        price: 159.99,
        imageUrl:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=2070&auto=format&fit=crop',
        category: 'Shoes',
        categoryId: 'shoes',
      ),
      const ProductModel(
        id: '2',
        name: 'Apple Watch Ultra',
        price: 799.00,
        imageUrl:
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=2099&auto=format&fit=crop',
        category: 'Watches',
        categoryId: 'watches',
        isFavorite: true,
      ),
      const ProductModel(
        id: '3',
        name: 'Sony WH-1000XM5',
        price: 349.50,
        imageUrl:
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=2070&auto=format&fit=crop',
        category: 'Audio',
        categoryId: 'audio',
      ),
      const ProductModel(
        id: '4',
        name: 'MacBook Pro M3',
        price: 1999.00,
        imageUrl:
            'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=2052&auto=format&fit=crop',
        category: 'Laptops',
        categoryId: 'laptops',
      ),
      const ProductModel(
        id: '5',
        name: 'iPhone 15 Pro',
        price: 999.00,
        imageUrl:
            'https://images.unsplash.com/photo-1696446701796-da61225697cc?q=80&w=2070&auto=format&fit=crop',
        category: 'Phones',
        categoryId: 'phones',
      ),
      const ProductModel(
        id: '6',
        name: 'Canon EOS R5',
        price: 3899.00,
        imageUrl:
            'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=2076&auto=format&fit=crop',
        category: 'Audio',
        categoryId: 'audio',
        isFavorite: true,
      ),
    ];

    state = state.copyWith(
      categories: categories,
      products: products,
      isLoading: false,
    );
  }

  void selectCategory(String categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateSortOption(ProductSortOption sortOption) {
    state = state.copyWith(sortOption: sortOption);
  }

  void toggleFavoritesOnly(bool enabled) {
    state = state.copyWith(favoritesOnly: enabled);
  }

  void toggleFavorite(String productId) {
    final updatedProducts = state.products.map((product) {
      if (product.id == productId) {
        return product.copyWith(isFavorite: !product.isFavorite);
      }
      return product;
    }).toList();
    state = state.copyWith(products: updatedProducts);
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  return HomeViewModel();
});
