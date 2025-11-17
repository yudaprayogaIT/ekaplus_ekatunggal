// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/check_phone_exists.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/register_user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_otp.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_otp.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckPhoneExists checkPhoneExists;
  final RequestOtp requestOtp;
  final VerifyOtp verifyOtp;
  final RegisterUser registerUser;

  AuthBloc({
    required this.checkPhoneExists,
    required this.requestOtp,
    required this.verifyOtp,
    required this.registerUser,
  }) : super(AuthInitial()) {
    on<CheckPhoneEvent>(_onCheckPhone);
    on<RequestOtpEvent>(_onRequestOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<RegisterUserEvent>(_onRegisterUser);
    on<ResetAuthEvent>(_onResetAuth);
  }

  Future<void> _onCheckPhone(
    CheckPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await checkPhoneExists(event.phone);

    result.fold(
      (failure) => emit(PhoneCheckError(failure.message ?? 'Unknown error')),
      (exists) => emit(PhoneCheckSuccess(exists)),
    );
  }

  Future<void> _onRequestOtp(
    RequestOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    print('🔄 Requesting OTP for: ${event.phone}');

    final result = await requestOtp(event.phone);

    result.fold(
      (failure) {
        print('❌ OTP Request Failed: ${failure.message}');
        emit(OtpRequestError(failure.message ?? 'Unknown error'));
      },
      (otp) {
        print('✅ OTP Request Success - 6 digit OTP: $otp');
        emit(OtpRequestSuccess(otp: otp, phone: event.phone));
      },
    );
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    print('🔄 Verifying OTP for: ${event.phone} with code: ${event.otp}');

    final result = await verifyOtp(event.phone, event.otp);

    result.fold(
      (failure) {
        print('❌ OTP Verification Failed: ${failure.message}');
        emit(OtpVerificationError(failure.message ?? 'Unknown error'));
      },
      (isValid) {
        if (isValid) {
          print('✅ OTP Verification Success for: ${event.phone}');
          emit(OtpVerificationSuccess(event.phone));
        } else {
          print('❌ OTP Invalid or Expired');
          emit(const OtpVerificationError(
              'OTP tidak valid atau sudah kadaluarsa'));
        }
      },
    );
  }

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    print('🔄 Registering user: ${event.phone}');

    final params = RegisterUserParams(
      phone: event.phone,
      name: event.name,
      email: event.email,
      birthDate: event.birthDate,
      birthPlace: event.birthPlace,
      password: event.password,
    );

    final result = await registerUser(params);

    result.fold(
      (failure) {
        print('❌ Registration Failed: ${failure.message}');
        emit(RegisterError(failure.message ?? 'Unknown error'));
      },
      (user) {
        print('✅ Registration Success: ${user.phone} - ${user.name}');
        emit(RegisterSuccess(user));
      },
    );
  }

  void _onResetAuth(ResetAuthEvent event, Emitter<AuthState> emit) {
    print('🔄 Resetting Auth State');
    emit(AuthInitial());
  }
}