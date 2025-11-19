// lib/features/auth/data/repositories/auth_repository_implementation.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/models/user_model.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/register_user.dart';

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
  Future<Either<Failure, User>> registerUser(RegisterUserParams params) async {
    try {
      // Generate unique ID
      final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();

      // Generate full name
      final fullName = '${params.firstName} ${params.lastName}';

      final userModel = UserModel(
        id: id,
        firstName: params.firstName,
        lastName: params.lastName,
        fullName: fullName,
        username: params.username,
        email: params.email,
        phone: params.phone,
        password: params.password,
        isEmailVerified: false,
        isPhoneVerified: true, // true karena sudah lewat OTP
        gender: params.gender,
        dateOfBirth: params.dateOfBirth,
        birthPlace: params.birthPlace,
        profilePic: null,
        picture: null,
        referralCode: null,
        referredBy: null,
        address: null,
        city: null,
        province: null,
        postalCode: null,
        country: null,
        googleId: null,
        googleAccessToken: null,
        googleRefreshToken: null,
        googleTokenExpiry: null,
        role: 'user',
        status: 'active',
        workflowState: 'registered',
        tokenVersion: 0,
        lastLogin: null,
        createdBy: null,
        updatedBy: null,
        createdAt: now,
        updatedAt: now,
        isSystem: false,
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