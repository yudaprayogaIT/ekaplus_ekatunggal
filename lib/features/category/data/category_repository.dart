// lib/features/category/data/category_repository.dart
import 'package:flutter/services.dart' show rootBundle;
import 'models/category_item.dart';

class CategoryRepository {
  final String assetPath;

  CategoryRepository({this.assetPath = 'assets/data/itemCategories.json'});

  Future<List<CategoryItem>> loadAll() async {
    final jsonStr = await rootBundle.loadString(assetPath);
    return CategoryItem.listFromJsonString(jsonStr);
  }
}
