// lib/features/category/data/models/category_item.dart
import 'dart:convert';

class CategoryItem {
  final String name;
  final String type;
  final String image;
  final String desc;
  final int poin;

  CategoryItem({
    required this.name,
    required this.type,
    required this.image,
    required this.desc,
    required this.poin,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      name: (json['name'] ?? '') as String,
      type: (json['type'] ?? '') as String,
      image: (json['image'] ?? '') as String,
      desc: (json['desc'] ?? '') as String,
      poin: (json['poin'] ?? 0) is int ? (json['poin'] as int) : int.parse('${json['poin']}'),
    );
  }

  static List<CategoryItem> listFromJsonString(String jsonStr) {
    final data = jsonDecode(jsonStr) as List<dynamic>;
    return data.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
