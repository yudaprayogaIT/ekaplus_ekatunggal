// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/register_user.dart';

abstract class AuthRepository {
  /// Check if phone number already exists
  Future<Either<Failure, bool>> checkPhoneExists(String phone);

  /// Request OTP for phone number
  Future<Either<Failure, String>> requestOtp(String phone);

  /// Verify OTP code
  Future<Either<Failure, bool>> verifyOtp(String phone, String otp);

  /// Register new user
  Future<Either<Failure, User>> registerUser(RegisterUserParams params);

  /// Get user by phone
  Future<Either<Failure, User>> getUserByPhone(String phone);

  // Login user with phone/username and password
  Future<Either<Failure, User>> loginUser(String identifier, String password);
}