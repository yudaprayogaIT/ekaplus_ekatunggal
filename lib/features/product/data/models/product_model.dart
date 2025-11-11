// lib/features/product/data/models/product_model.dart
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';

class TypeModel extends TypeEntity {
  const TypeModel({required super.id, required super.name});

  factory TypeModel.fromJson(Map<String, dynamic> json) {
    return TypeModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class ItemCategoryModel extends ItemCategoryEntity {
  const ItemCategoryModel({required super.id, required super.name});

  factory ItemCategoryModel.fromJson(Map<String, dynamic> json) {
    return ItemCategoryModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class VariantModel extends VariantEntity {
  const VariantModel({
    required super.id,
    required super.code,
    required super.name,
    super.color = "",
    super.type = "",
    super.description = "",
    super.image = "",
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'color': color,
      'type': type,
      'description': description,
      'image': image,
    };
  }
}

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.type,
    super.itemCategory,
    super.variants = const [],
    super.disabled = 0,
    super.isHotDeals = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse array variants
    List<VariantModel> variantsList = [];
    if (json['variants'] != null && json['variants'] is List) {
      variantsList = (json['variants'] as List)
          .map((v) => VariantModel.fromJson(v))
          .toList();
    }

    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] != null ? TypeModel.fromJson(json['type']) : null,
      itemCategory: json['itemCategory'] != null
          ? ItemCategoryModel.fromJson(json['itemCategory'])
          : null,
      variants: variantsList,
      disabled: json['disabled'] ?? 0,
      isHotDeals: json['isHotDeals'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "type": type != null ? (type as TypeModel).toJson() : null,
      "itemCategory": itemCategory != null
          ? (itemCategory as ItemCategoryModel).toJson()
          : null,
      "variants": variants.map((v) => (v as VariantModel).toJson()).toList(),
      "disabled": disabled,
      "isHotDeals": isHotDeals,
    };
  }

  static List<ProductModel> fromJsonList(List data) {
    if (data.isEmpty) return [];
    return data.map((item) => ProductModel.fromJson(item)).toList();
  }
}
