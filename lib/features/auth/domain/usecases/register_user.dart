import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<Either<Failure, User>> call(RegisterUserParams params) {
    return repository.registerUser(
      phone: params.phone,
      name: params.name,
      email: params.email,
      birthDate: params.birthDate,
      birthPlace: params.birthPlace,
      password: params.password,
    );
  }
}

class RegisterUserParams extends Equatable {
  final String phone;
  final String name;
  final String email;
  final String birthDate;
  final String birthPlace;
  final String password;

  const RegisterUserParams({
    required this.phone,
    required this.name,
    required this.email,
    required this.birthDate,
    required this.birthPlace,
    required this.password,
  });

  @override
  List<Object> get props => [phone, name, email, birthDate, birthPlace, password];
}