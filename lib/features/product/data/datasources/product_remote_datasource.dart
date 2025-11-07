// lib/features/product/data/datasources/product_remote_datasource.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ekaplus_ekatunggal/features/product/data/models/product_model.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:http/http.dart' as http;

abstract class ProductRemoteDatasource {
  Future<List<Product>> getAllProduct(int page);
  Future<Product> getProduct(String id);
  Future<VariantEntity?> getVariant(String variantId); // ⚠️ TAMBAH: untuk get variant by ID
}

class ProductRemoteDatasourceImplementation extends ProductRemoteDatasource {
  final http.Client client;

  ProductRemoteDatasourceImplementation({required this.client});

  @override
  Future<List<Product>> getAllProduct(int page) async {
    // API DEVELOPMENT ambil dari JSON nanti hapus saat deployment
    final String body = await rootBundle.loadString(
      'assets/data/products.json',
    );
    final dynamic decoded = jsonDecode(body);

    // file adalah array top-level
    final List<dynamic> data = decoded is List
        ? decoded
        : (decoded['data'] ?? []);

    List<ProductModel> result = ProductModel.fromJsonList(data);

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
    final String body = await rootBundle.loadString(
      'assets/data/products.json',
    );
    final dynamic decoded = jsonDecode(body);
    final List<dynamic> list = decoded is List
        ? decoded
        : (decoded['data'] ?? []);

    final int idInt = int.tryParse(id) ?? -1;
    
    // ⚠️ PERBAIKI: Cari product by ID
    final found = list.firstWhere(
      (e) {
        if (e is Map<String, dynamic>) {
          final dynamic rawId = e['id'];
          return rawId == idInt || rawId.toString() == id;
        }
        return false;
      },
      orElse: () => null,
    );

    if (found == null) {
      throw Exception("Product with id $id not found");
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
    //   throw Exception("Product not found");
    // } else {
    //   throw Exception("Cannot get data");
    // }
  }

  // ⚠️ TAMBAH: Method untuk get variant by ID
  @override
  Future<VariantEntity?> getVariant(String variantId) async {
    final String body = await rootBundle.loadString(
      'assets/data/products.json',
    );
    final dynamic decoded = jsonDecode(body);
    final List<dynamic> list = decoded is List
        ? decoded
        : (decoded['data'] ?? []);

    final int variantIdInt = int.tryParse(variantId) ?? -1;

    // Cari variant di semua products
    for (var productData in list) {
      if (productData is Map<String, dynamic>) {
        final variants = productData['variants'] as List<dynamic>?;
        if (variants != null) {
          for (var variantData in variants) {
            if (variantData is Map<String, dynamic>) {
              final dynamic rawId = variantData['id'];
              if (rawId == variantIdInt || rawId.toString() == variantId) {
                return VariantModel.fromJson(variantData);
              }
            }
          }
        }
      }
    }

    throw Exception("Variant with id $variantId not found");
  }
}