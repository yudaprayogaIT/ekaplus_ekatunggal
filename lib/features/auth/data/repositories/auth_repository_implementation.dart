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
      final id = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();
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
        isPhoneVerified: true,
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

  @override
  Future<Either<Failure, User>> loginUser(
    String identifier,
    String password,
  ) async {
    try {
      print('🔍 Attempting login with: $identifier');

      UserModel? user;

      // Check if identifier is phone or username
      if (identifier.startsWith('0') ||
          identifier.startsWith('62') ||
          identifier.contains(RegExp(r'^\d+$'))) {
        // Normalize phone number
        String normalizedPhone = identifier.replaceAll(RegExp(r'[^0-9]'), '');
        if (normalizedPhone.startsWith('0')) {
          normalizedPhone = '62${normalizedPhone.substring(1)}';
        }

        print('🔍 Searching by phone: $normalizedPhone');
        user = await localDataSource.getUserByPhone(normalizedPhone);
      } else {
        // Search by username
        print('🔍 Searching by username: $identifier');
        user = await localDataSource.getUserByUsername(identifier);
      }

      if (user == null) {
        print('❌ User not found: $identifier');
        return const Left(
          CacheFailure(message: 'Username atau nomor HP tidak ditemukan'),
        );
      }

      // Verify password
      if (user.password != password) {
        print('❌ Invalid password for user: $identifier');
        return const Left(
          CacheFailure(message: 'Password yang Anda masukkan salah'),
        );
      }

      print('✅ Login successful: ${user.username}');

      // Update last login
      final updatedUser = user.copyWith(
        lastLogin: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await localDataSource.updateUser(updatedUser);

      return Right(updatedUser);
    } catch (e) {
      print('❌ Login error: $e');
      return Left(CacheFailure(message: 'Terjadi kesalahan saat login'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfilePicture(
    String userId,
    String? profilePicPath,
    String? bgColor,
  ) async {
    try {
      print('🔄 Updating profile picture for user: $userId');

      // Get current user
      final user = await localDataSource.getUserByPhone(userId);
      if (user == null) {
        return const Left(CacheFailure(message: 'User not found'));
      }

      // Update profile picture
      final updatedUser = user.copyWith(
        profilePic: profilePicPath,
        profileBgColor: bgColor,
        updatedAt: DateTime.now(),
      );

      await localDataSource.updateUser(updatedUser);

      print('✅ Profile picture updated successfully');
      return Right(updatedUser);
    } catch (e) {
      print('❌ Error updating profile picture: $e');
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
