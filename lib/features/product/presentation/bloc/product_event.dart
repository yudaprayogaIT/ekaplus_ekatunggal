// lib/features/product/presentation/bloc/product_event.dart
part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

// Get All Products
class ProductEventGetAllProducts extends ProductEvent {
  final int page;

  const ProductEventGetAllProducts([this.page = 1]); // 🔥 Default value = 1

  @override
  List<Object> get props => [page];
}

// Get Product Detail
class ProductEventGetDetailProduct extends ProductEvent {
  final String productId;

  const ProductEventGetDetailProduct(this.productId);

  @override
  List<Object> get props => [productId];
}

// Get Variant
class ProductEventGetVariant extends ProductEvent {
  final String variantId;

  const ProductEventGetVariant(this.variantId);

  @override
  List<Object> get props => [variantId];
}

// Get Hot Deals
class ProductEventGetHotDeals extends ProductEvent {
  const ProductEventGetHotDeals();
}