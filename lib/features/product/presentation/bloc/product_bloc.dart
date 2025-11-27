// lib/features/product/presentation/bloc/product_bloc.dart
import 'package:bloc/bloc.dart';
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

  // 🔥 CACHE: Store loaded products to prevent unnecessary reloads
  List<Product>? _cachedProducts;
  DateTime? _lastFetchTime;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  ProductBloc({
    required this.getAllProduct,
    required this.getProduct,
    required this.getVariant,
    required this.getHotDeals,
  }) : super(ProductInitial()) {
    
    // Get All Products
    on<ProductEventGetAllProducts>((event, emit) async {
      // 🔥 CHECK CACHE: If we have cached data and it's not expired, use it
      if (_cachedProducts != null && 
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheExpiration) {
        print('✅ Using cached products (${_cachedProducts!.length} items)');
        emit(ProductLoaded(_cachedProducts!));
        return;
      }

      // Only show loading if no cache available
      if (_cachedProducts == null) {
        emit(ProductLoading());
      }

      final result = await getAllProduct.execute(event.page);

      result.fold(
        (failure) {
          // If fetch fails but we have cache, use cache
          if (_cachedProducts != null) {
            print('⚠️ Fetch failed, using cached products');
            emit(ProductLoaded(_cachedProducts!));
          } else {
            emit(ProductError(failure.message ?? 'Cannot get products'));
          }
        },
        (products) {
          // 🔥 UPDATE CACHE
          _cachedProducts = products;
          _lastFetchTime = DateTime.now();
          print('✅ Products cached (${products.length} items)');
          emit(ProductLoaded(products));
        },
      );
    });

    // Force Refresh (bypass cache)
    on<ProductEventRefreshProducts>((event, emit) async {
      emit(ProductLoading());

      final result = await getAllProduct.execute(1);

      result.fold(
        (failure) => emit(ProductError(failure.message ?? 'Cannot get products')),
        (products) {
          _cachedProducts = products;
          _lastFetchTime = DateTime.now();
          print('✅ Products refreshed and cached');
          emit(ProductLoaded(products));
        },
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
      // 🔥 If we have cached products, filter from cache
      if (_cachedProducts != null) {
        final hotDeals = _cachedProducts!.where((p) => p.isHotDeals).toList();
        print('✅ Using cached hot deals (${hotDeals.length} items)');
        emit(ProductLoaded(hotDeals));
        return;
      }

      emit(ProductLoading());

      final result = await getHotDeals.execute();

      result.fold(
        (failure) => emit(ProductError(failure.message ?? 'Cannot get hot deals')),
        (hotDeals) => emit(ProductLoaded(hotDeals)),
      );
    });

    // 🔥 NEW: Clear cache when needed
    on<ProductEventClearCache>((event, emit) {
      _cachedProducts = null;
      _lastFetchTime = null;
      print('🗑️ Product cache cleared');
    });
  }

  // 🔥 Helper: Check if cache is valid
  bool get hasCachedData => _cachedProducts != null;
  
  bool get isCacheExpired {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) >= _cacheExpiration;
  }
}