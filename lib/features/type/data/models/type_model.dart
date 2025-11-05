// lib/features/type/data/models/type_model.dart
import 'package:ekaplus_ekatunggal/features/type/domain/entities/type.dart';


class UserModel{
  final int id;
  final String name;

  UserModel({
    required this.id,
    required this.name,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TypeModel extends Type {
  const TypeModel({
   required super.id,
    required super.name,
    super.image,
    super.description,
    super.docstatus = 0,
    super.status,
    super.typeName,
    super.disabled = false,
    required super.updatedAt,
    super.updatedBy,
    required super.createdAt,
    super.createdBy,
    super.owner
  });

  factory TypeModel.fromJson(Map<String, dynamic> dataJson) {
    Map<String, dynamic> data = dataJson;

    return TypeModel(
      id: data['id'],
      name: data['name'],
      image: data['image'],
      description: data['description'],
      docstatus: data['docstatus'],
      status: data['status'],
      typeName: data['type_name'],
      disabled: data['disabled'],
      updatedAt: DateTime.parse(data['updated_at']),
      updatedBy: data['updated_by'],
      createdAt: DateTime.parse(data['created_at']),
      createdBy: data['created_by'],
      owner: data['owner']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "image": image,
      "description": description,
      "docstatus": docstatus,
      "status": status,
      "type_name": typeName,
      "disabled": disabled,
      "updated_at": updatedAt.toIso8601String(),
      "updated_by": updatedBy,
      "created_at": createdAt.toIso8601String(),
      "created_by": createdBy,
      "owner": owner,
    };
  }

  static List<TypeModel> fromJsonList(List data) {
    if (data.isEmpty) return [];
    return data
        .map((singleDataItem) => TypeModel.fromJson(singleDataItem))
        .toList();
  }
}
