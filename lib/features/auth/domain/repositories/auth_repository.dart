// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/register_user.dart';

abstract class AuthRepository {
  // Existing methods
  Future<Either<Failure, bool>> checkPhoneExists(String phone);
  Future<Either<Failure, String>> requestOtp(String phone);
  Future<Either<Failure, bool>> verifyOtp(String phone, String otp);
  Future<Either<Failure, User>> registerUser(RegisterUserParams params);
  Future<Either<Failure, User>> getUserByPhone(String phone);
  Future<Either<Failure, User>> loginUser(String identifier, String password);
  Future<Either<Failure, User>> updateProfilePicture(
    String userId,
    String? profilePicPath,
    String? bgColor,
  );

  // Profile update methods
  Future<Either<Failure, User>> updateFullName(String userId, String fullName);
  
  Future<Either<Failure, String>> requestPhoneChange({
    required String userId,
    required String newPhone,
    required String password,
  });
  
  Future<Either<Failure, User>> verifyPhoneChange({
    required String userId,
    required String newPhone,
    required String verificationCode,
  });
  
  Future<Either<Failure, String>> requestEmailChange({
    required String userId,
    required String newEmail,
    required String password,
  });
  
  Future<Either<Failure, User>> verifyEmailChange({
    required String userId,
    required String newEmail,
    required String verificationCode,
  });

   Future<Either<Failure, bool>> verifyOldPassword({
    required String userId,
    required String oldPassword,
  });
  
  Future<Either<Failure, User>> changePassword({
    required String userId,
    required String newPassword,
    String? oldPassword,
  });
  
  Future<Either<Failure, User>> resetPasswordWithOtp({
    required String phone,
    required String newPassword,
  });
}