part of 'product_bloc.dart';

// PASTIKAN TIDAK ADA DEFINISI VariantEntity di file ini!

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

// State untuk loaded variant (VariantEntity sudah diimpor di product_bloc.dart)
class ProductStateLoadedVariant extends ProductState {
  final VariantEntity variant;

  ProductStateLoadedVariant(this.variant);
  
  @override
  List<Object?> get props => [variant];
}

class ProductStateLoadedHotDeals extends ProductState {
  final List<Product> hotDeals;

  ProductStateLoadedHotDeals(this.hotDeals);

  @override
  List<Object?> get props => [hotDeals];
}