// // lib/features/product/presentation/bloc/product_bloc.dart
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/constants.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_all_product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_product.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';

part 'product_event.dart';
part 'product_state.dart';

class SubProduct {
  String name;
  bool status;

  SubProduct(this.name, this.status);
}

class ResponseSub {
  final List<List<String>> filters;
  final List<SubProduct> subProduct;
  ResponseSub(this.filters, this.subProduct);
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetAllProduct getAllProduct;
  final GetProduct getProduct;
  int selectedImage = 0;

  Future<ResponseSub> getSubProduct(String id) async {
    List<SubProduct> subProduct = [SubProduct(id, true)];
    List<List<String>> filters = [
      ["item_group", "=", id],
    ];
    try {
      String encodedId = Uri.encodeComponent(id);
      Uri uri = Uri.parse(
        "${Constants.apiBaseUrl}/api/public/Item Group/$encodedId",
      );

      var response = await http.Client().get(uri);

      if (response.statusCode == 200) {
        Map<String, dynamic> dataBody = jsonDecode(response.body);
        List<dynamic> childs = dataBody['childs'];
        if (childs.isNotEmpty) {
          List<SubProduct> genSub = childs.map((item) {
            return SubProduct(item["name"], false);
          }).toList();
          subProduct = [...subProduct, ...genSub];
          List<List<String>> genFilters = childs.map<List<String>>((item) {
            return ["item_group", "=", item["name"] as String];
          }).toList();

          filters = [...filters, ...genFilters];
        }
      }
      // ignore: empty_catches
    } catch (e) {}
    return ResponseSub(filters, subProduct);
  }

  ProductBloc({required this.getAllProduct, required this.getProduct})
    : super(ProductStateEmpty()) {
    on<ProductEventGetAllProducts>((event, emit) async {
      emit(ProductStateLoading());

      Either<Failure, List<Product>> resultGetAllProduct = await getAllProduct.execute(
        event.page,
      );

      resultGetAllProduct.fold(
        (l) => emit(ProductStateError('Cannot get all Products')),
        (r) => emit(ProductStateLoadedAllProduct(r)),
      );
    });

    on<ProductEventGetDetailProduct>((event, emit) async {
      emit(ProductStateLoading());

      Either<Failure, Product> productResult = await getProduct.execute(event.productId);

      productResult.fold(
        (l) => emit(ProductStateError('Cannot get Product details')),
        (r) => emit(ProductStateLoadedProduct(r)),
      );
    });
  }
}
