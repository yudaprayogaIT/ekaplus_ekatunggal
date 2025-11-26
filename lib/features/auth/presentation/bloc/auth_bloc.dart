// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/check_phone_exists.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/login_user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/register_user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/request_otp.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/verify_otp.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/update_profile_picture.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckPhoneExists checkPhoneExists;
  final RequestOtp requestOtp;
  final VerifyOtp verifyOtp;
  final RegisterUser registerUser;
  final LoginUser loginUser;
  final UpdateProfilePicture updateProfilePicture;

  AuthBloc({
    required this.checkPhoneExists,
    required this.requestOtp,
    required this.verifyOtp,
    required this.registerUser,
    required this.loginUser,
    required this.updateProfilePicture,
  }) : super(AuthInitial()) {
    on<CheckPhoneEvent>(_onCheckPhone);
    on<CheckPhoneExistsEvent>(_onCheckPhoneExists);
    on<RequestOtpEvent>(_onRequestOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<RegisterUserEvent>(_onRegisterUser);
    on<LoginUserEvent>(_onLoginUser);
    on<ResetAuthEvent>(_onResetAuth);
    on<UpdateProfilePictureEvent>(_onUpdateProfilePicture);
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

  // Handler khusus untuk forgot password flow
  Future<void> _onCheckPhoneExists(
    CheckPhoneExistsEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    print('🔍 Checking if phone exists: ${event.phone}');

    final result = await checkPhoneExists(event.phone);

    result.fold(
      (failure) {
        print('❌ Phone check failed: ${failure.message}');
        emit(AuthError(failure.message ?? 'Gagal mengecek nomor handphone'));
      },
      (exists) {
        if (exists) {
          print('✅ Phone exists: ${event.phone}');
          emit(PhoneExistsState(true));
        } else {
          print('❌ Phone not found: ${event.phone}');
          emit(const PhoneNotFoundError('Nomor handphone tidak terdaftar'));
        }
      },
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
          emit(
            const OtpVerificationError('OTP tidak valid atau sudah kadaluarsa'),
          );
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
      firstName: event.firstName,
      lastName: event.lastName,
      username: event.username,
      email: event.email,
      password: event.password,
      gender: event.gender,
      dateOfBirth: event.dateOfBirth,
      birthPlace: event.birthPlace,
    );

    final result = await registerUser(params);

    result.fold(
      (failure) {
        print('❌ Registration Failed: ${failure.message}');
        emit(RegisterError(failure.message ?? 'Unknown error'));
      },
      (user) {
        print('✅ Registration Success: ${user.phone} - ${user.fullName}');
        emit(RegisterSuccess(user));
      },
    );
  }

  Future<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    print('🔄 Login attempt: ${event.identifier}');

    final result = await loginUser(event.identifier, event.password);

    result.fold(
      (failure) {
        print('❌ Login Failed: ${failure.message}');
        emit(LoginError(failure.message ?? 'Login gagal'));
      },
      (user) {
        print('✅ Login Success: ${user.username} - ${user.fullName}');
        emit(LoginSuccess(user));
      },
    );
  }

  void _onResetAuth(ResetAuthEvent event, Emitter<AuthState> emit) {
    print('🔄 Resetting Auth State');
    emit(AuthInitial());
  }

  Future<void> _onUpdateProfilePicture(
    UpdateProfilePictureEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    print('🔄 Updating profile picture for: ${event.userId}');

    final result = await updateProfilePicture(
      event.userId,
      event.profilePicPath,
      event.bgColor,
    );

    result.fold(
      (failure) {
        print('❌ Profile Picture Update Failed: ${failure.message}');
        emit(ProfilePictureUpdateError(failure.message ?? 'Update failed'));
      },
      (user) {
        print(
          '✅ Profile Picture Updated: ${user.profilePic} with color: ${user.profileBgColor}',
        );
        emit(ProfilePictureUpdateSuccess(user));
      },
    );
  }
}