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

  // ========== PROFILE UPDATE METHODS ==========

  @override
  Future<Either<Failure, User>> updateFullName(
    String userId,
    String fullName,
  ) async {
    try {
      print('🔄 Updating full name for user: $userId');

      // Get current user by phone (userId is phone in local storage)
      final user = await localDataSource.getUserByPhone(userId);
      if (user == null) {
        return const Left(CacheFailure(message: 'User tidak ditemukan'));
      }

      // Split full name into first and last name
      final nameParts = fullName.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      // Update user
      final updatedUser = user.copyWith(
        firstName: firstName,
        lastName: lastName,
        fullName: fullName.trim(),
        updatedAt: DateTime.now(),
      );

      await localDataSource.updateUser(updatedUser);

      print('✅ Full name updated successfully');
      return Right(updatedUser);
    } catch (e) {
      print('❌ Error updating full name: $e');
      return Left(
        CacheFailure(message: 'Gagal mengubah nama: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> requestPhoneChange({
    required String userId,
    required String newPhone,
    required String password,
  }) async {
    try {
      print('🔄 Requesting phone change for user: $userId');

      // Get current user
      final user = await localDataSource.getUserByPhone(userId);
      if (user == null) {
        return const Left(CacheFailure(message: 'User tidak ditemukan'));
      }

      // Verify password
      if (user.password != password) {
        return const Left(CacheFailure(message: 'Password salah'));
      }

      // Check if new phone already exists
      final phoneExists = await localDataSource.checkPhoneExists(newPhone);
      if (phoneExists) {
        return const Left(
          CacheFailure(message: 'Nomor handphone sudah digunakan'),
        );
      }

      // Generate OTP for new phone
      final otp = await localDataSource.generateOtp(newPhone);

      print('✅ OTP sent to new phone: $newPhone');
      return Right('Kode verifikasi telah dikirim ke $newPhone. Kode: $otp');
    } catch (e) {
      print('❌ Error requesting phone change: $e');
      return Left(CacheFailure(message: 'Gagal mengirim kode verifikasi'));
    }
  }

  @override
Future<Either<Failure, User>> verifyPhoneChange({
  required String userId,
  required String newPhone,
  required String verificationCode,
}) async {
  try {
    print('🔄 Verifying phone change for user: $userId');

    // Verify OTP
    final isValid = await localDataSource.verifyOtp(newPhone, verificationCode);
    if (!isValid) {
      return const Left(CacheFailure(message: 'Kode verifikasi tidak valid atau sudah kadaluarsa'));
    }

    // Get current user by OLD phone (userId)
    final user = await localDataSource.getUserByPhone(userId);
    if (user == null) {
      return const Left(CacheFailure(message: 'User tidak ditemukan'));
    }

    print('📱 Old phone: ${user.phone}');
    print('📱 New phone: $newPhone');

    // Create updated user with new phone
    final updatedUser = user.copyWith(
      phone: newPhone,
      isPhoneVerified: true,
      updatedAt: DateTime.now(),
    );

    // ⚠️ CRITICAL: Use special method to update phone (changes the key)
    await localDataSource.updateUserPhone(
      userId, // old phone
      newPhone, // new phone
      updatedUser,
    );

    print('✅ Phone changed successfully');
    return Right(updatedUser);
  } catch (e) {
    print('❌ Error verifying phone change: $e');
    return Left(CacheFailure(message: 'Gagal mengubah nomor handphone: ${e.toString()}'));
  }
}

  @override
  Future<Either<Failure, String>> requestEmailChange({
    required String userId,
    required String newEmail,
    required String password,
  }) async {
    try {
      print('🔄 Requesting email change for user: $userId');

      // Get current user
      final user = await localDataSource.getUserByPhone(userId);
      if (user == null) {
        return const Left(CacheFailure(message: 'User tidak ditemukan'));
      }

      // Verify password
      if (user.password != password) {
        return const Left(CacheFailure(message: 'Password salah'));
      }

      // Check if email already exists
      final emailUser = await localDataSource.getUserByEmail(newEmail);
      if (emailUser != null && emailUser.phone != userId) {
        return const Left(CacheFailure(message: 'Email sudah digunakan'));
      }

      // Generate OTP for verification (using phone as identifier)
      final otp = await localDataSource.generateOtp('email_$newEmail');

      print('✅ Verification code sent to email: $newEmail');
      return Right('Kode verifikasi telah dikirim ke $newEmail. Kode: $otp');
    } catch (e) {
      print('❌ Error requesting email change: $e');
      return Left(CacheFailure(message: 'Gagal mengirim kode verifikasi'));
    }
  }

  @override
  Future<Either<Failure, User>> verifyEmailChange({
    required String userId,
    required String newEmail,
    required String verificationCode,
  }) async {
    try {
      print('🔄 Verifying email change for user: $userId');

      // Verify OTP
      final isValid = await localDataSource.verifyOtp(
        'email_$newEmail',
        verificationCode,
      );
      if (!isValid) {
        return const Left(
          CacheFailure(
            message: 'Kode verifikasi tidak valid atau sudah kadaluarsa',
          ),
        );
      }

      // Get current user
      final user = await localDataSource.getUserByPhone(userId);
      if (user == null) {
        return const Left(CacheFailure(message: 'User tidak ditemukan'));
      }

      // Update email
      final updatedUser = user.copyWith(
        email: newEmail,
        isEmailVerified: true,
        updatedAt: DateTime.now(),
      );

      await localDataSource.updateUser(updatedUser);

      print('✅ Email changed successfully');
      return Right(updatedUser);
    } catch (e) {
      print('❌ Error verifying email change: $e');
      return Left(CacheFailure(message: 'Gagal mengubah email'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOldPassword({
    required String userId,
    required String oldPassword,
  }) async {
    try {
      print('🔐 Verifying old password for user: $userId');

      // Get current user
      final user = await localDataSource.getUserByPhone(userId);
      if (user == null) {
        return const Left(CacheFailure(message: 'User tidak ditemukan'));
      }

      // Verify password
      if (user.password != oldPassword) {
        return const Left(CacheFailure(message: 'Password lama salah'));
      }

      print('✅ Old password verified');
      return const Right(true);
    } catch (e) {
      print('❌ Error verifying old password: $e');
      return Left(CacheFailure(message: 'Gagal memverifikasi password'));
    }
  }

  @override
  Future<Either<Failure, User>> changePassword({
    required String userId,
    required String newPassword,
    String? oldPassword,
  }) async {
    try {
      print('🔄 Changing password for user: $userId');

      // Get current user
      final user = await localDataSource.getUserByPhone(userId);
      if (user == null) {
        return const Left(CacheFailure(message: 'User tidak ditemukan'));
      }

      // If oldPassword provided, verify it
      if (oldPassword != null) {
        if (user.password != oldPassword) {
          return const Left(CacheFailure(message: 'Password lama salah'));
        }
      }

      // Update password
      final updatedUser = user.copyWith(
        password: newPassword,
        updatedAt: DateTime.now(),
      );

      await localDataSource.updateUser(updatedUser);

      print('✅ Password changed successfully');
      return Right(updatedUser);
    } catch (e) {
      print('❌ Error changing password: $e');
      return Left(CacheFailure(message: 'Gagal mengubah password'));
    }
  }

  @override
  Future<Either<Failure, User>> resetPasswordWithOtp({
    required String phone,
    required String newPassword,
  }) async {
    try {
      print('🔄 Resetting password with OTP for: $phone');

      // Get user by phone
      final user = await localDataSource.getUserByPhone(phone);
      if (user == null) {
        return const Left(CacheFailure(message: 'User tidak ditemukan'));
      }

      // Update password (OTP already verified)
      final updatedUser = user.copyWith(
        password: newPassword,
        updatedAt: DateTime.now(),
      );

      await localDataSource.updateUser(updatedUser);

      print('✅ Password reset successfully');
      return Right(updatedUser);
    } catch (e) {
      print('❌ Error resetting password: $e');
      return Left(CacheFailure(message: 'Gagal mereset password'));
    }
  }
}
