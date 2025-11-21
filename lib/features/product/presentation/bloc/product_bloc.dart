// lib/features/product/presentation/bloc/product_bloc.dart
import 'package:bloc/bloc.dart';
// import 'package:dartz/dartz.dart';
// import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_all_product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_hot_deals.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_variant.dart';
import 'package:equatable/equatable.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetAllProduct getAllProduct;
  final GetProduct getProduct;
  final GetVariant getVariant;
  final GetHotDeals getHotDeals;

  ProductBloc({
    required this.getAllProduct,
    required this.getProduct,
    required this.getVariant,
    required this.getHotDeals,
  }) : super(ProductInitial()) {
    
    // Get All Products
    on<ProductEventGetAllProducts>((event, emit) async {
      if (event.page == 1) {
        emit(ProductLoading());
      }

      final result = await getAllProduct.execute(event.page);

      result.fold(
        (failure) => emit(ProductError(failure.message ?? 'Cannot get products')),
        (products) => emit(ProductLoaded(products)),
      );
    });

    // Get Product Detail
    on<ProductEventGetDetailProduct>((event, emit) async {
      emit(ProductLoading());

      final result = await getProduct.execute(event.productId);

      result.fold(
        (failure) => emit(ProductError(failure.message ?? 'Cannot get product details')),
        (product) => emit(ProductDetailLoaded(product)),
      );
    });

    // Get Variant
    on<ProductEventGetVariant>((event, emit) async {
      emit(ProductLoading());

      final result = await getVariant.execute(event.variantId);

      result.fold(
        (failure) => emit(ProductError(failure.message ?? 'Cannot get variant')),
        (variant) {
          if (variant != null) {
            emit(ProductVariantLoaded(variant));
          } else {
            emit(const ProductError('Variant not found'));
          }
        },
      );
    });

    // Get Hot Deals
    on<ProductEventGetHotDeals>((event, emit) async {
      emit(ProductLoading());

      final result = await getHotDeals.execute();

      result.fold(
        (failure) => emit(ProductError(failure.message ?? 'Cannot get hot deals')),
        (hotDeals) => emit(ProductLoaded(hotDeals)),
      );
    });
  }
}