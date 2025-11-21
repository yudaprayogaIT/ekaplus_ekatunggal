// lib/features/product/presentation/bloc/product_state.dart
part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

// Initial State
class ProductInitial extends ProductState {}

// Loading State
class ProductLoading extends ProductState {}

// Error State
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

// Loaded All Products State
class ProductLoaded extends ProductState {
  final List<Product> products;

  const ProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

// Loaded Product Detail State
class ProductDetailLoaded extends ProductState {
  final Product product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

// Loaded Variant State
class ProductVariantLoaded extends ProductState {
  final VariantEntity variant;

  const ProductVariantLoaded(this.variant);

  @override
  List<Object?> get props => [variant];
}