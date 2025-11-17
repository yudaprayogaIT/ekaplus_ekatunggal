import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckPhoneEvent extends AuthEvent {
  final String phone;

  const CheckPhoneEvent(this.phone);

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
  final String name;
  final String email;
  final String birthDate;
  final String birthPlace;
  final String password;

  const RegisterUserEvent({
    required this.phone,
    required this.name,
    required this.email,
    required this.birthDate,
    required this.birthPlace,
    required this.password,
  });

  @override
  List<Object> get props => [
        phone,
        name,
        email,
        birthDate,
        birthPlace,
        password,
      ];
}

class ResetAuthEvent extends AuthEvent {}