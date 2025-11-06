// // lib/features/category/presentation/bloc/category_bloc.dart
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/constants.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/usecases/get_all_category.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/usecases/get_category.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';

part 'category_event.dart';
part 'category_state.dart';

class SubCategory {
  String name;
  bool status;

  SubCategory(this.name, this.status);
}

class ResponseSub {
  final List<List<String>> filters;
  final List<SubCategory> subCategory;
  ResponseSub(this.filters, this.subCategory);
}

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetAllCategory getAllCategory;
  final GetCategory getCategory;
  int selectedImage = 0;

  Future<ResponseSub> getSubCategory(String id) async {
    List<SubCategory> subCategory = [SubCategory(id, true)];
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
          List<SubCategory> genSub = childs.map((item) {
            return SubCategory(item["name"], false);
          }).toList();
          subCategory = [...subCategory, ...genSub];
          List<List<String>> genFilters = childs.map<List<String>>((item) {
            return ["item_group", "=", item["name"] as String];
          }).toList();

          filters = [...filters, ...genFilters];
        }
      }
      // ignore: empty_catches
    } catch (e) {}
    return ResponseSub(filters, subCategory);
  }

  CategoryBloc({required this.getAllCategory, required this.getCategory})
    : super(CategoryStateEmpty()) {
    on<CategoryEventGetAllCategories>((event, emit) async {
      emit(CategoryStateLoading());

      Either<Failure, List<Category>> resultGetAllCategory = await getAllCategory.execute(
        event.page,
      );

      resultGetAllCategory.fold(
        (l) => emit(CategoryStateError('Cannot get all Categorys')),
        (r) => emit(CategoryStateLoadedAllCategory(r)),
      );
    });

    on<CategoryEventGetDetailCategory>((event, emit) async {
      emit(CategoryStateLoading());

      Either<Failure, Category> categoryResult = await getCategory.execute(event.categoryId);

      categoryResult.fold(
        (l) => emit(CategoryStateError('Cannot get Category details')),
        (r) => emit(CategoryStateLoadedCategory(r)),
      );
    });
  }
}
