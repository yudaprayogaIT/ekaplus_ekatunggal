// lib/features/auth/data/datasources/auth_local_datasource.dart
import 'dart:math';
import 'package:ekaplus_ekatunggal/core/services/storage_service.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/models/otp_model.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<bool> checkPhoneExists(String phone);
  Future<String> generateOtp(String phone);
  Future<bool> verifyOtp(String phone, String otp);
  Future<UserModel> saveUser(UserModel user);
  Future<UserModel?> getUserByPhone(String phone);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final StorageService _storageService = StorageService();

  Future<String> exportUsersAsJson() async {
  return await _storageService.exportUsersAsJson();
}

  @override
  Future<bool> checkPhoneExists(String phone) async {
    try {
      final users = await _storageService.loadUsers();
      return users.any((u) => u['phone'] == phone);
    } catch (e) {
      print('❌ Error checking phone exists: $e');
      return false;
    }
  }

  @override
  Future<String> generateOtp(String phone) async {
    final random = Random();

    // Generate 6 digit OTP (100000 - 999999)
    final otp = (100000 + random.nextInt(900000)).toString();

    // Save OTP session
    final otpSession = {
      'phone': phone,
      'otp': otp,
      'created_at': DateTime.now().toIso8601String(),
      'expires_at': DateTime.now()
          .add(const Duration(minutes: 5))
          .toIso8601String(),
      'is_used': false,
    };

    await _storageService.saveOtpSession(otpSession);

    print('✅ Generated 6-digit OTP for $phone: $otp');
    return otp;
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    // Development OTP - always valid
    if (otp == '123456') {
      print('✅ Development OTP accepted: 123456');
      return true;
    }

    try {
      final sessions = await _storageService.loadOtpSessions();
      
      final session = sessions.firstWhere(
        (s) => s['phone'] == phone && s['otp'] == otp,
        orElse: () => {},
      );

      if (session.isEmpty) {
        print('❌ OTP not found for $phone');
        return false;
      }

      // Check if expired
      final expiresAt = DateTime.parse(session['expires_at'] as String);
      if (DateTime.now().isAfter(expiresAt)) {
        print('❌ OTP expired for $phone');
        return false;
      }

      // Check if already used
      if (session['is_used'] == true) {
        print('❌ OTP already used for $phone');
        return false;
      }

      // Mark as used
      session['is_used'] = true;
      await _storageService.saveOtpSession(session);

      print('✅ OTP verified successfully for $phone');
      return true;
    } catch (e) {
      print('❌ Error verifying OTP: $e');
      return false;
    }
  }

  @override
  Future<UserModel> saveUser(UserModel user) async {
    try {
      print('💾 Saving user to storage...');
      print('📱 Phone: ${user.phone}');
      print('👤 Name: ${user.fullName}');
      print('📧 Email: ${user.email}');

      // Convert UserModel to Map
      final userMap = user.toJson();

      // Save using StorageService
      await _storageService.saveUser(userMap);

      print('✅ User saved successfully!');
      return user;
    } catch (e) {
      print('❌ Error saving user: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel?> getUserByPhone(String phone) async {
    try {
      final userMap = await _storageService.getUserByPhone(phone);
      
      if (userMap == null || userMap.isEmpty) {
        print('⚠️ User not found: $phone');
        return null;
      }

      return UserModel.fromJson(userMap);
    } catch (e) {
      print('❌ Error getting user by phone: $e');
      return null;
    }
  }

  // Additional methods using StorageService

  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final userMap = await _storageService.getUserByUsername(username);
      
      if (userMap == null || userMap.isEmpty) {
        return null;
      }

      return UserModel.fromJson(userMap);
    } catch (e) {
      print('❌ Error getting user by username: $e');
      return null;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final userMap = await _storageService.getUserByEmail(email);
      
      if (userMap == null || userMap.isEmpty) {
        return null;
      }

      return UserModel.fromJson(userMap);
    } catch (e) {
      print('❌ Error getting user by email: $e');
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      final updates = user.toJson();
      await _storageService.updateUser(user.phone, updates);
    } catch (e) {
      print('❌ Error updating user: $e');
      rethrow;
    }
  }

  Future<String> getStorageFilePath() async {
    return await _storageService.getUsersFilePath();
  }
}