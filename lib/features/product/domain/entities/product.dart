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
  final String code;
  final String name;
  final String color;
  final String type;
  final String image;

  const VariantEntity({
    required this.id, 
    required this.code, 
    required this.name, 
    required this.color, 
    required this.type, 
    this.image = ""
  });

  @override
  List<Object?> get props => [id, code, name, color, type, image];
}

class Product extends Equatable {
  final int id;
  final String name;
  final CategoryEntity? category;
  final List<VariantEntity> variants; // ⚠️ Ubah jadi List
  final int disabled;
  final bool isHotDeals;

  const Product({
    required this.id,
    required this.name,
    this.category,
    this.variants = const [], // ⚠️ Default empty list
    this.disabled = 0,
    this.isHotDeals = false
  });

  @override
  List<Object?> get props => [id, name, category, variants, disabled, isHotDeals];
}