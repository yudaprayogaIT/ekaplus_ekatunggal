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

  const VariantEntity({
    required this.id, 
    required this.name, 
    required this.code, 
    this.image = ""
  });

  @override
  List<Object?> get props => [id, name, code, image];
}

class Product extends Equatable {
  final int id;
  final String name;
  final CategoryEntity? category;
  final List<VariantEntity> variants; // ⚠️ Ubah jadi List
  final int disabled;

  const Product({
    required this.id,
    required this.name,
    this.category,
    this.variants = const [], // ⚠️ Default empty list
    this.disabled = 0,
  });

  @override
  List<Object?> get props => [id, name, category, variants, disabled];
}