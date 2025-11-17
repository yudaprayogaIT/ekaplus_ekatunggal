// lib/features/auth/data/repositories/auth_repository_implementation.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/models/user_model.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImplementation implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImplementation({required this.localDataSource});

  @override
  Future<Either<Failure, bool>> checkPhoneExists(String phone) async {
    try {
      final exists = await localDataSource.checkPhoneExists(phone);
      return Right(exists);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> requestOtp(String phone) async {
    try {
      final otp = await localDataSource.generateOtp(phone);
      return Right(otp);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp(String phone, String otp) async {
    try {
      final isValid = await localDataSource.verifyOtp(phone, otp);
      return Right(isValid);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> registerUser({
    required String phone,
    required String name,
    required String email,
    required String birthDate,
    required String birthPlace,
    required String password,
  }) async {
    try {
      // Generate unique ID
      final id = 'user_${DateTime.now().millisecondsSinceEpoch}';

      final userModel = UserModel(
        id: id,
        phone: phone,
        name: name,
        email: email,
        birthDate: birthDate,
        birthPlace: birthPlace,
        password: password,
        status: 'active',
        createdAt: DateTime.now(),
      );

      final savedUser = await localDataSource.saveUser(userModel);
      return Right(savedUser);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserByPhone(String phone) async {
    try {
      final user = await localDataSource.getUserByPhone(phone);
      if (user == null) {
        return const Left(CacheFailure(message: 'User not found'));
      }
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}