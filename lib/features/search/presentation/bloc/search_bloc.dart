// lib/features/search/presentation/bloc/search_bloc.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ekaplus_ekatunggal/features/product/data/models/product_model.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/category/data/models/category_model.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  List<Product> _allProducts = [];
  List<Category> _allCategories = [];

  SearchBloc() : super(const SearchStateLoading()) {
    on<SearchEventInitial>(_onInitial);
    on<SearchEventQueryChanged>(_onQueryChanged);
    on<SearchEventClearQuery>(_onClearQuery);
  }

  Future<void> _onInitial(
    SearchEventInitial event,
    Emitter<SearchState> emit,
  ) async {
    try {
      emit(const SearchStateLoading());

      // Load products
      final productsJson = await rootBundle.loadString('assets/data/products.json');
      final dynamic decodedProducts = jsonDecode(productsJson);
      final List<dynamic> productsList = decodedProducts is List
          ? decodedProducts
          : (decodedProducts['data'] ?? []);
      _allProducts = ProductModel.fromJsonList(productsList);

      // Load categories
      final categoriesJson = await rootBundle.loadString('assets/data/itemCategories.json');
      final List<dynamic> categoriesList = jsonDecode(categoriesJson);
      _allCategories = categoriesList
          .map((json) => CategoryModel.fromJson(json))
          .toList();

      // Filter hot deals
      final hotDeals = _allProducts
          .where((product) => product.isHotDeals == true)
          .take(4)
          .toList();

      emit(SearchStateInitial(
        hotDeals: hotDeals,
        categories: _allCategories,
      ));
    } catch (e) {
      emit(SearchStateError('Gagal memuat data: ${e.toString()}'));
    }
  }

  Future<void> _onQueryChanged(
    SearchEventQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      final hotDeals = _allProducts
          .where((product) => product.isHotDeals == true)
          .take(4)
          .toList();

      emit(SearchStateInitial(
        hotDeals: hotDeals,
        categories: _allCategories,
      ));
      return;
    }

    final results = _allProducts.where((product) {
      final nameLower = product.name.toLowerCase();
      final queryLower = query.toLowerCase();
      
      if (nameLower.contains(queryLower)) return true;
      
      if (product.itemCategory?.name.toLowerCase().contains(queryLower) ?? false) {
        return true;
      }
      
      for (var variant in product.variants) {
        final variantName = (variant as dynamic).name ?? '';
        final variantCode = (variant as dynamic).code ?? '';
        final variantType = (variant as dynamic).type ?? '';
        
        if (variantName.toLowerCase().contains(queryLower) ||
            variantCode.toLowerCase().contains(queryLower) ||
            variantType.toLowerCase().contains(queryLower)) {
          return true;
        }
      }
      
      return false;
    }).toList();

    if (results.isEmpty) {
      emit(SearchStateEmpty(query));
    } else {
      emit(SearchStateLoaded(query: query, results: results));
    }
  }

  Future<void> _onClearQuery(
    SearchEventClearQuery event,
    Emitter<SearchState> emit,
  ) async {
    final hotDeals = _allProducts
        .where((product) => product.isHotDeals == true)
        .take(4)
        .toList();

    emit(SearchStateInitial(
      hotDeals: hotDeals,
      categories: _allCategories,
    ));
  }
}