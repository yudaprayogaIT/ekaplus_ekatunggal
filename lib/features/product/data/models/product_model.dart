// lib/features/product/data/models/product_model.dart
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({required super.id, required super.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0, 
      name: json['name'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class VariantModel extends VariantEntity {
  const VariantModel({
    required super.id,
    required super.name,
    required super.code,
    super.image = "",
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'name': name, 
      'code': code, // ⚠️ Perbaiki: tadinya 'code': 'code' (hardcoded string)
      'image': image // ⚠️ Perbaiki: tadinya 'image': 'image'
    };
  }
}

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.category,
    super.variants = const [], // ⚠️ Ubah jadi List
    super.disabled = 0,
    super.isHotDeals = false
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // ⚠️ Parse array variants
    List<VariantModel> variantsList = [];
    if (json['variants'] != null && json['variants'] is List) {
      variantsList = (json['variants'] as List)
          .map((v) => VariantModel.fromJson(v))
          .toList();
    }

    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      variants: variantsList, // ⚠️ Assign list
      disabled: json['disabled'] ?? 0,
      isHotDeals: json['isHotDeals'] ?? false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "category": category != null
          ? (category as CategoryModel).toJson()
          : null,
      "variants": variants // ⚠️ Ubah jadi variants (plural)
          .map((v) => (v as VariantModel).toJson())
          .toList(),
      "disabled": disabled,
      "isHotDeals": isHotDeals
    };
  }

  static List<ProductModel> fromJsonList(List data) {
    if (data.isEmpty) return [];
    return data
        .map((item) => ProductModel.fromJson(item))
        .toList();
  }
}