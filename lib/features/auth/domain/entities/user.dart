// lib/features/auth/domain/entities/user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  // Basic Info
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String password;

  // Verification
  final bool isEmailVerified;
  final bool isPhoneVerified;

  // Personal Info
  final String gender;
  final String dateOfBirth;
  final String birthPlace;

  // Profile
  final String? profilePic;
  final String? picture; // Google profile picture

  // Referral
  final String? referralCode;
  final String? referredBy;

  // Member Info (null saat register, diisi saat pengajuan member)
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? country;

  // Google Auth
  final String? googleId;
  final String? googleAccessToken;
  final String? googleRefreshToken;
  final DateTime? googleTokenExpiry;

  // System
  final String role;
  final String status;
  final String workflowState;
  final int tokenVersion;
  final DateTime? lastLogin;
  final String? createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSystem;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    this.isEmailVerified = false,
    this.isPhoneVerified = true, // true karena sudah lewat OTP
    required this.gender,
    required this.dateOfBirth,
    required this.birthPlace,
    this.profilePic,
    this.picture,
    this.referralCode,
    this.referredBy,
    this.address,
    this.city,
    this.province,
    this.postalCode,
    this.country,
    this.googleId,
    this.googleAccessToken,
    this.googleRefreshToken,
    this.googleTokenExpiry,
    this.role = 'user',
    this.status = 'active',
    this.workflowState = 'registered',
    this.tokenVersion = 0,
    this.lastLogin,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.isSystem = false,
  });

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    fullName,
    username,
    email,
    phone,
    password,
    isEmailVerified,
    isPhoneVerified,
    gender,
    dateOfBirth,
    birthPlace,
    profilePic,
    picture,
    referralCode,
    referredBy,
    address,
    city,
    province,
    postalCode,
    country,
    googleId,
    googleAccessToken,
    googleRefreshToken,
    googleTokenExpiry,
    role,
    status,
    workflowState,
    tokenVersion,
    lastLogin,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
    isSystem,
  ];
}
