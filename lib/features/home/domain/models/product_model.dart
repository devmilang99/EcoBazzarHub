import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final double price;
  final String image;
  final String categoryId;
  final bool isFavorite;
  final String description;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.categoryId,
    this.isFavorite = false,
    this.description = 'Premium quality product for you.',
  });

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    String? categoryId,
    bool? isFavorite,
    String? description,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id, name, price, image, categoryId, isFavorite, description];
}
