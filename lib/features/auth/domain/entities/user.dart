// lib/features/auth/domain/entities/user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? birthDate;
  final String? birthPlace;
  final String? password;
  final String status; // 'pending', 'active', 'inactive'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.birthDate,
    this.birthPlace,
    this.password,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        phone,
        name,
        email,
        birthDate,
        birthPlace,
        password,
        status,
        createdAt,
        updatedAt,
      ];
}