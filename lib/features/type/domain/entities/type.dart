// lib/features/type/domain/entities/type.dart
import 'package:equatable/equatable.dart';

class Type extends Equatable {
  final int? id;
  final String name;
  final String? image;
  final String? description;
  final int? docstatus;
  final String? status;
  final bool? disabled;
  final String? typeName;
  final DateTime updatedAt;
  final int? updatedBy;
  final DateTime createdAt;
  final int? createdBy;
  final int? owner;

  const Type({
    required this.id,
    required this.name,
    this.image = "",
    this.description = "",
    this.docstatus = 0,
    this.status = "",
    this.disabled = false,
    this.typeName = "",
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
    disabled,
    docstatus,
    status,
    typeName,
    updatedAt,
    updatedBy,
    createdAt,
    createdBy,
    owner,
  ];
}
