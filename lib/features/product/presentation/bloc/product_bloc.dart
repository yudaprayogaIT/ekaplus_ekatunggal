// lib/features/product/presentation/bloc/product_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
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
  final GetVariant getVariant; // ⚠️ TAMBAH
   final GetHotDeals getHotDeals;

  ProductBloc({
    required this.getAllProduct,
    required this.getProduct,
    required this.getVariant, // ⚠️ TAMBAH
    required this.getHotDeals,
  }) : super(ProductStateEmpty()) {
    on<ProductEventGetAllProducts>((event, emit) async {
      emit(ProductStateLoading());

      Either<Failure, List<Product>> resultGetAllProduct = 
          await getAllProduct.execute(event.page);

      resultGetAllProduct.fold(
        (failure) => emit(ProductStateError(failure.message ?? 'Cannot get all Products')), // ⚠️ PERBAIKI
        (products) => emit(ProductStateLoadedAllProduct(products)),
      );
    });

    on<ProductEventGetDetailProduct>((event, emit) async {
      emit(ProductStateLoading());

      Either<Failure, Product> productResult = 
          await getProduct.execute(event.productId);

      productResult.fold(
        (failure) => emit(ProductStateError(failure.message ?? 'Cannot get Product details')), // ⚠️ PERBAIKI
        (product) => emit(ProductStateLoadedProduct(product)),
      );
    });

    // ⚠️ TAMBAH: Event handler untuk get variant
    on<ProductEventGetVariant>((event, emit) async {
      emit(ProductStateLoading());

      Either<Failure, VariantEntity?> variantResult = 
          await getVariant.execute(event.variantId);

      variantResult.fold(
        (failure) => emit(ProductStateError(failure.message ?? 'Cannot get Variant details')),
        (variant) {
          if (variant != null) {
            emit(ProductStateLoadedVariant(variant));
          } else {
            emit(ProductStateError('Variant not found'));
          }
        },
      );
    });

    on<ProductEventGetHotDeals>((event, emit) async {
      emit(ProductStateLoading());
      final result = await getHotDeals.execute();
      result.fold(
        (failure) => emit(ProductStateError(failure.message ?? 'Cannot get Hot Deals details')),
        (hotDeals) => emit(ProductStateLoadedHotDeals(hotDeals)),
      );
    });
  }
}