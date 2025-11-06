// lib/features/category/domain/entities/category.dart
import 'package:equatable/equatable.dart';

class TypeEntity extends Equatable {
  final int id;
  final String name;

  const TypeEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class UserEntity extends Equatable {
  final int id;
  final String name;

  const UserEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class Category extends Equatable {
  final int id;
  final String name;
  final String? image;
  final String? description;
  final TypeEntity? type;
  final int? docstatus;
  final String? status;
  final int? disabled;
  final DateTime? updatedAt;
  final UserEntity? updatedBy;
  final DateTime createdAt;
  final UserEntity? createdBy;
  final UserEntity? owner;

  const Category({
    required this.id,
    required this.name,
    this.image = "",
    this.description = "",
    required this.type,
    this.docstatus = 0,
    this.status = "",
    this.disabled = 0,
    required this.updatedAt,
    this.updatedBy,
    required this.createdAt,
    this.createdBy,
    this.owner,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    image,
    description,
    type,
    docstatus,
    status,
    disabled,
    updatedAt,
    updatedBy,
    createdAt,
    createdBy,
    owner,
  ];
}
