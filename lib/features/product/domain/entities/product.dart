// lib/features/product/domain/entities/product.dart
import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String name;

  const CategoryEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class VariantEntity extends Equatable {
  final int id;
  final String name;
  final String code;
  final String image;

  const VariantEntity({required this.id, required this.name, required this.code, this.image = ""});

  @override
  List<Object?> get props => [id, name, code, image];
}

class Product extends Equatable {
  final int id;
  final String name;
  final CategoryEntity? category;
  final VariantEntity? variant;
  final int? disabled;
  

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.variant,
    this.disabled
  });

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    variant,
    disabled,
  ];
}
