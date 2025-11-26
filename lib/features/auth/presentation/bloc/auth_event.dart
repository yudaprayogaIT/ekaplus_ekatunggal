// lib/features/auth/presentation/bloc/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckPhoneEvent extends AuthEvent {
  final String phone;

  const CheckPhoneEvent(this.phone);

  @override
  List<Object> get props => [phone];
}

// Event khusus untuk forgot password - cek apakah phone terdaftar
class CheckPhoneExistsEvent extends AuthEvent {
  final String phone;

  const CheckPhoneExistsEvent(this.phone);

  @override
  List<Object> get props => [phone];
}

class RequestOtpEvent extends AuthEvent {
  final String phone;

  const RequestOtpEvent(this.phone);

  @override
  List<Object> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;

  const VerifyOtpEvent(this.phone, this.otp);

  @override
  List<Object> get props => [phone, otp];
}

class RegisterUserEvent extends AuthEvent {
  final String phone;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String gender;
  final String dateOfBirth;
  final String birthPlace;

  const RegisterUserEvent({
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    required this.gender,
    required this.dateOfBirth,
    required this.birthPlace,
  });

  @override
  List<Object?> get props => [
    phone,
    firstName,
    lastName,
    username,
    email,
    password,
    gender,
    dateOfBirth,
    birthPlace,
  ];
}

class LoginUserEvent extends AuthEvent {
  final String identifier; // phone or username
  final String password;

  const LoginUserEvent({
    required this.identifier,
    required this.password,
  });

  @override
  List<Object> get props => [identifier, password];
}

class UpdateProfilePictureEvent extends AuthEvent {
  final String userId;
  final String? profilePicPath;
  final String? bgColor;

  const UpdateProfilePictureEvent({
    required this.userId,
    required this.profilePicPath,
    this.bgColor,
  });

  @override
  List<Object?> get props => [userId, profilePicPath, bgColor];
}

class ResetAuthEvent extends AuthEvent {}