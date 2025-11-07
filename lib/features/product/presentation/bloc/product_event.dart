// lib/features/product/presentation/bloc/product_event.dart
part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class ProductEventGetAllProducts extends ProductEvent {
  final int page;

  const ProductEventGetAllProducts(this.page);

  @override
  List<Object> get props => [page]; // ⚠️ PERBAIKI: tambahkan page ke props
}

class ProductEventGetDetailProduct extends ProductEvent {
  final String productId;

  const ProductEventGetDetailProduct(this.productId);

  @override
  List<Object> get props => [productId];
}

// ⚠️ TAMBAH: Event baru untuk get variant
class ProductEventGetVariant extends ProductEvent {
  final String variantId;

  const ProductEventGetVariant(this.variantId);

  @override
  List<Object> get props => [variantId];
}
