// // lib/features/type/data/datasources/type_remote_datasource.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:ekaplus_ekatunggal/core/constants.dart';
import 'package:ekaplus_ekatunggal/features/type/data/models/type_model.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/entities/type.dart';
import 'package:http/http.dart' as http;

abstract class TypeRemoteDatasource {
  Future<List<Type>> getAllType(int page);
  Future<Type> getType(String id);
}

class TypeRemoteDatasourceImplementation extends TypeRemoteDatasource {
  final http.Client client;

  TypeRemoteDatasourceImplementation({required this.client});

  // List<List<String>> isFilters = [
  //   ["parent_tree", "=", ""],
  //   ["is_group", "=", "true"],
  // ];

  @override
  Future<List<Type>> getAllType(int page) async {

    // API DEVELOPMENT ambil dari JSON nanti hapus saat deployment
    // load dari asset lokal
    final String body = await rootBundle.loadString(
      'assets/data/itemType.json',
    );
    final dynamic decoded = jsonDecode(body);

    // file adalah array top-level
    final List<dynamic> data = decoded is List
        ? decoded
        : (decoded['data'] ?? []);
  
    List<TypeModel> result = TypeModel.fromJsonList(data);

    print(result);
    return result;

    // // panggilan API REAL pakai ini saat deployment
    // final Uri uri = Uri.parse("${Constants.apiBaseUrl}/api/public/Item Group");
    // final response = await client.get(uri);
    // if (response.statusCode == 200) {
    //   final Map<String, dynamic> dataBody = jsonDecode(response.body);
    //   final List<dynamic> data = dataBody['data'] ?? [];
    //   return TypeModel.fromJsonList(data);
    // } else {
    //   throw Exception("Cannot get data (status ${response.statusCode})");
    // }
  }

  @override
  Future<Type> getType(String id) async {
    // API DEVELOPMENT ambil dari JSON nanti hapus saat deployment
    // load dari asset lokal
    final String body = await rootBundle.loadString(
      'assets/data/itemType.json',
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
    return TypeModel.fromJson(found);

    // // panggilan API REAL pakai ini saat deployment
    // final String encodedId = Uri.encodeComponent(id);
    // final Uri uri = Uri.parse("${Constants.apiBaseUrl}/api/public/Item Group/$encodedId");
    // final response = await client.get(uri);
    // if (response.statusCode == 200) {
    //   final Map<String, dynamic> dataBody = jsonDecode(response.body);
    //   final Map<String, dynamic> data = dataBody['data'];
    //   return TypeModel.fromJson(data);
    // } else if (response.statusCode == 404) {
    //   throw Exception("data not found");
    // } else {
    //   throw Exception("Cannot get data");
    // }
  }
}
