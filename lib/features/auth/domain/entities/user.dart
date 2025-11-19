// lib/features/auth/domain/entities/user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String phone;
  final String name;
  final String email;
  final String birthDate;
  final String birthPlace;
  final String password;
  final String status;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.phone,
    required this.name,
    required this.email,
    required this.birthDate,
    required this.birthPlace,
    required this.password,
    required this.status,
    required this.createdAt,
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
      ];
}