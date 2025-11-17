// lib/features/auth/data/datasources/auth_local_datasource.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
  final String usersFileName = 'users.json';
  final String otpFileName = 'otp_sessions.json';

  // key untuk SharedPreferences (fallback)
  final String _prefsUsersKey = 'ekaplus_users_json';
  final String _prefsOtpKey = 'ekaplus_otp_json';

  // Determine storage mode at runtime
  bool? _usePrefs; // null = not initialized yet

  Future<void> _ensureInit() async {
    if (_usePrefs != null) return;
    // If running on web, prefer SharedPreferences
    if (kIsWeb) {
      _usePrefs = true;
      return;
    }
    try {
      // Try to resolve application documents directory
      final dir = await getApplicationDocumentsDirectory();
      // if we get here without exception, use file storage
      _usePrefs = false;
    } on MissingPluginException catch (_) {
      // plugin not registered (e.g., running tests or plugin not available)
      _usePrefs = true;
    } catch (_) {
      // any other error -> fallback to prefs
      _usePrefs = true;
    }
  }

  // ---------- File helpers ----------
  Future<Directory> _getAppDocDir() async {
    return await getApplicationDocumentsDirectory();
  }

  Future<File> _getUsersFile() async {
    final dir = await _getAppDocDir();
    final path = p.join(dir.path, usersFileName);
    final file = File(path);
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(json.encode({'users': []}));
    }
    return file;
  }

  Future<File> _getOtpFile() async {
    final dir = await _getAppDocDir();
    final path = p.join(dir.path, otpFileName);
    final file = File(path);
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(json.encode({'otp_sessions': []}));
    }
    return file;
  }

  // ---------- SharedPreferences helpers ----------
  Future<SharedPreferences> _prefs() async {
    return await SharedPreferences.getInstance();
  }

  // ---------- Read / Write wrappers ----------
  Future<List<UserModel>> _readUsersFromFile() async {
    try {
      final file = await _getUsersFile();
      final contents = await file.readAsString();
      final jsonData = json.decode(contents);
      final List<dynamic> usersJson = jsonData['users'] ?? [];
      return usersJson.map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      // on error return empty
      return [];
    }
  }

  Future<void> _writeUsersToFile(List<UserModel> users) async {
    final file = await _getUsersFile();
    final jsonData = {'users': users.map((u) => u.toJson()).toList()};
    await file.writeAsString(json.encode(jsonData));
  }

  Future<List<OtpModel>> _readOtpsFromFile() async {
    try {
      final file = await _getOtpFile();
      final contents = await file.readAsString();
      final jsonData = json.decode(contents);
      final List<dynamic> otpJson = jsonData['otp_sessions'] ?? [];
      return otpJson.map((e) => OtpModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _writeOtpsToFile(List<OtpModel> sessions) async {
    final file = await _getOtpFile();
    final jsonData = {'otp_sessions': sessions.map((o) => o.toJson()).toList()};
    await file.writeAsString(json.encode(jsonData));
  }

  Future<List<UserModel>> _readUsersFromPrefs() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_prefsUsersKey) ?? '{"users": []}';
    final jsonData = json.decode(raw);
    final List<dynamic> usersJson = jsonData['users'] ?? [];
    return usersJson.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<void> _writeUsersToPrefs(List<UserModel> users) async {
    final prefs = await _prefs();
    final jsonData = {'users': users.map((u) => u.toJson()).toList()};
    await prefs.setString(_prefsUsersKey, json.encode(jsonData));
  }

  Future<List<OtpModel>> _readOtpsFromPrefs() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_prefsOtpKey) ?? '{"otp_sessions": []}';
    final jsonData = json.decode(raw);
    final List<dynamic> otpJson = jsonData['otp_sessions'] ?? [];
    return otpJson.map((e) => OtpModel.fromJson(e)).toList();
  }

  Future<void> _writeOtpsToPrefs(List<OtpModel> sessions) async {
    final prefs = await _prefs();
    final jsonData = {'otp_sessions': sessions.map((o) => o.toJson()).toList()};
    await prefs.setString(_prefsOtpKey, json.encode(jsonData));
  }

  // ---------- Public API implementations ----------
  @override
  Future<bool> checkPhoneExists(String phone) async {
    await _ensureInit();
    if (_usePrefs == true) {
      final users = await _readUsersFromPrefs();
      return users.any((u) => u.phone == phone);
    } else {
      final users = await _readUsersFromFile();
      return users.any((u) => u.phone == phone);
    }
  }

  @override
  Future<String> generateOtp(String phone) async {
    await _ensureInit();
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();

    if (_usePrefs == true) {
      final sessions = await _readOtpsFromPrefs();
      sessions.removeWhere((s) => s.phone == phone);
      final newSession = OtpModel(
        phone: phone,
        otp: otp,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        isUsed: false,
      );
      sessions.add(newSession);
      await _writeOtpsToPrefs(sessions);
    } else {
      final sessions = await _readOtpsFromFile();
      sessions.removeWhere((s) => s.phone == phone);
      final newSession = OtpModel(
        phone: phone,
        otp: otp,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        isUsed: false,
      );
      sessions.add(newSession);
      await _writeOtpsToFile(sessions);
    }

    // For dev/debugging return otp
    print('Generated OTP for $phone: $otp');
    return otp;
  }

  @override
  Future<bool> verifyOtp(String phone, String otp) async {
    await _ensureInit();

    // Accept development OTP
    if (otp == '123456') return true;

    if (_usePrefs == true) {
      final sessions = await _readOtpsFromPrefs();
      final idx = sessions.indexWhere(
        (s) => s.phone == phone && s.otp == otp && s.isValid,
      );
      if (idx == -1) return false;
      sessions[idx] = sessions[idx].copyWith(isUsed: true);
      await _writeOtpsToPrefs(sessions);
      return true;
    } else {
      final sessions = await _readOtpsFromFile();
      final idx = sessions.indexWhere(
        (s) => s.phone == phone && s.otp == otp && s.isValid,
      );
      if (idx == -1) return false;
      sessions[idx] = sessions[idx].copyWith(isUsed: true);
      await _writeOtpsToFile(sessions);
      return true;
    }
  }

  @override
  Future<UserModel> saveUser(UserModel user) async {
    await _ensureInit();

    if (_usePrefs == true) {
      final users = await _readUsersFromPrefs();
      final existingIndex = users.indexWhere((u) => u.phone == user.phone);
      if (existingIndex != -1) {
        users[existingIndex] = user;
      } else {
        users.add(user);
      }
      await _writeUsersToPrefs(users);
      return user;
    } else {
      final users = await _readUsersFromFile();
      final existingIndex = users.indexWhere((u) => u.phone == user.phone);
      if (existingIndex != -1) {
        users[existingIndex] = user;
      } else {
        users.add(user);
      }
      await _writeUsersToFile(users);
      return user;
    }
  }

  @override
  Future<UserModel?> getUserByPhone(String phone) async {
    await _ensureInit();
    if (_usePrefs == true) {
      final users = await _readUsersFromPrefs();
      try {
        return users.firstWhere((u) => u.phone == phone);
      } catch (e) {
        return null;
      }
    } else {
      final users = await _readUsersFromFile();
      try {
        return users.firstWhere((u) => u.phone == phone);
      } catch (e) {
        return null;
      }
    }
  }
}
