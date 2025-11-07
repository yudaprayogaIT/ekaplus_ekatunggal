// // lib/features/product/data/datasources/product_remote_datasource.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:ekaplus_ekatunggal/core/constants.dart';
import 'package:ekaplus_ekatunggal/features/product/data/models/product_model.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:http/http.dart' as http;

abstract class ProductRemoteDatasource {
  Future<List<Product>> getAllProduct(int page);
  Future<Product> getProduct(String id);
}

class ProductRemoteDatasourceImplementation extends ProductRemoteDatasource {
  final http.Client client;

  ProductRemoteDatasourceImplementation({required this.client});

  // List<List<String>> isFilters = [
  //   ["parent_tree", "=", ""],
  //   ["is_group", "=", "true"],
  // ];

  @override
  Future<List<Product>> getAllProduct(int page) async {

    // API DEVELOPMENT ambil dari JSON nanti hapus saat deployment
    // load dari asset lokal
    final String body = await rootBundle.loadString(
      'assets/data/products.json',
    );
    final dynamic decoded = jsonDecode(body);

    // file adalah array top-level
    final List<dynamic> data = decoded is List
        ? decoded
        : (decoded['data'] ?? []);

    List<ProductModel> result = ProductModel.fromJsonList(data);

    // print(result);
    return result;

    // // panggilan API REAL pakai ini saat deployment
    // final Uri uri = Uri.parse("${Constants.apiBaseUrl}/api/public/Item Group");
    // final response = await client.get(uri);
    // if (response.statusCode == 200) {
    //   final Map<String, dynamic> dataBody = jsonDecode(response.body);
    //   final List<dynamic> data = dataBody['data'] ?? [];
    //   return ProductModel.fromJsonList(data);
    // } else {
    //   throw Exception("Cannot get data (status ${response.statusCode})");
    // }
  }

  @override
  Future<Product> getProduct(String id) async {
    // API DEVELOPMENT ambil dari JSON nanti hapus saat deployment
    // load dari asset lokal
    final String body = await rootBundle.loadString(
      'assets/data/products.json',
    );
    final dynamic decoded = jsonDecode(body);
    final List<dynamic> list = decoded is List
        ? decoded
        : (decoded['data'] ?? []);

    final int idInt = int.tryParse(id) ?? -1;
    final found = list.firstWhere((e) {
      if (e is Map<String, dynamic>) {
        // JSON id mungkin int
        final dynamic rawId = e['id'];
        return rawId == idInt || rawId.toString() == id;
      }
      return false;
    }, orElse: () => null);

    if (found == null) {
      throw Exception("data not found");
    }
    return ProductModel.fromJson(found);

    // // panggilan API REAL pakai ini saat deployment
    // final String encodedId = Uri.encodeComponent(id);
    // final Uri uri = Uri.parse("${Constants.apiBaseUrl}/api/public/Item Group/$encodedId");
    // final response = await client.get(uri);
    // if (response.statusCode == 200) {
    //   final Map<String, dynamic> dataBody = jsonDecode(response.body);
    //   final Map<String, dynamic> data = dataBody['data'];
    //   return ProductModel.fromJson(data);
    // } else if (response.statusCode == 404) {
    //   throw Exception("data not found");
    // } else {
    //   throw Exception("Cannot get data");
    // }
  }
}
