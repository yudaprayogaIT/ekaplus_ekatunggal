// lib/features/product/presentation/bloc/product_state.dart
part of 'product_bloc.dart';

abstract class ProductState extends Equatable {}

class ProductStateEmpty extends ProductState {
  @override
  List<Object?> get props => [];
}

class ProductStateLoading extends ProductState {
  @override
  List<Object?> get props => [];
}

class ProductStateError extends ProductState {
  final String message;

  ProductStateError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ProductStateLoadedAllProduct extends ProductState {
  final List<Product> allProduct;

  ProductStateLoadedAllProduct(this.allProduct);
  
  @override
  List<Object?> get props => [allProduct];
}

class ProductStateLoadedProduct extends ProductState {
  final Product detailProduct;

  ProductStateLoadedProduct(this.detailProduct);
  
  @override
  List<Object?> get props => [detailProduct];
}

// ⚠️ TAMBAH: State baru untuk loaded variant
class ProductStateLoadedVariant extends ProductState {
  final VariantEntity variant;

  ProductStateLoadedVariant(this.variant);
  
  @override
  List<Object?> get props => [variant];
}