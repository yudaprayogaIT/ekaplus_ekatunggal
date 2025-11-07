// lib/features/product/data/models/product_model.dart
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({required super.id, required super.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(id: json['id'] ?? 0, name: json['name'] ?? '');
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
    return {'id': id, 'name': name, code: 'code', image: 'image'};
  }
}

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.category,
    super.variant,
    super.disabled = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> dataJson) {
    Map<String, dynamic> data = dataJson;

    return ProductModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      category: data['category'] != null
          ? CategoryModel.fromJson(data['category'])
          : null,
      variant: data['variant'] != null
          ? VariantModel.fromJson(data['variant'])
          : null,
      disabled: data['disabled'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "category": category != null
          ? (category as CategoryModel).toJson()
          : null,
      "variant": variant != null ? (variant as VariantModel).toJson() : null,
      "disabled": disabled,
    };
  }

  static List<ProductModel> fromJsonList(List data) {
    if (data.isEmpty) return [];
    return data
        .map((singleDataItem) => ProductModel.fromJson(singleDataItem))
        .toList();
  }
}
