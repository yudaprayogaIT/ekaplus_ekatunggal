import 'package:equatable/equatable.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// --- Phone Check States ---
class PhoneCheckSuccess extends AuthState {
  final bool exists; // true jika nomor sudah terdaftar, false jika belum
  const PhoneCheckSuccess(this.exists);
  @override
  List<Object> get props => [exists];
}

class PhoneCheckError extends AuthState {
  final String message;
  const PhoneCheckError(this.message);
  @override
  List<Object> get props => [message];
}

// --- OTP Request States ---
class OtpRequestSuccess extends AuthState {
  final String otp; // Kirimkan OTP (untuk debug/dev)
  final String phone;
  const OtpRequestSuccess({required this.otp, required this.phone});
  @override
  List<Object> get props => [otp, phone];
}

class OtpRequestError extends AuthState {
  final String message;
  const OtpRequestError(this.message);
  @override
  List<Object> get props => [message];
}

// --- OTP Verification States ---
class OtpVerificationSuccess extends AuthState {
  final String phone;
  const OtpVerificationSuccess(this.phone);
  @override
  List<Object> get props => [phone];
}

class OtpVerificationError extends AuthState {
  final String message;
  const OtpVerificationError(this.message);
  @override
  List<Object> get props => [message];
}

// --- Register States ---
class RegisterSuccess extends AuthState {
  final User user;
  const RegisterSuccess(this.user);
  @override
  List<Object> get props => [user];
}

class RegisterError extends AuthState {
  final String message;
  const RegisterError(this.message);
  @override
  List<Object> get props => [message];
}