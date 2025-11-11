// lib/features/product/domain/entities/product.dart
import 'package:equatable/equatable.dart';

class TypeEntity extends Equatable {
  final int id;
  final String name;

  const TypeEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class ItemCategoryEntity extends Equatable {
  final int id;
  final String name;

  const ItemCategoryEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class VariantEntity extends Equatable {
  final int id;
  final String code;
  final String name;
  final String color;
  final String type;
  final String image;
  final String description;

  const VariantEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.color,
    required this.type,
    required this.description,
    this.image = "",
  });

  @override
  List<Object?> get props => [id, code, name, color, type, image, description];
}

class Product extends Equatable {
  final int id;
  final String name;
  final TypeEntity? type;
  final ItemCategoryEntity? itemCategory;
  final List<VariantEntity> variants;
  final int disabled;
  final bool isHotDeals;

  const Product({
    required this.id,
    required this.name,
    this.type,
    this.itemCategory,
    this.variants = const [],
    this.disabled = 0,
    this.isHotDeals = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    itemCategory,
    variants,
    disabled,
    isHotDeals,
  ];
}