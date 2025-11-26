// lib/features/auth/presentation/pages/otp_verification_page.dart
import 'dart:async';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/cubit/profile_update_cubit.dart';
import 'package:ekaplus_ekatunggal/features/account/presentation/pages/edit_contact_page.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/auth_state.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_bloc.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String? title;
  final String? subtitle;
  final String? nextRoute;
  final bool isPasswordReset;
  final ProfileUpdateCubit? cubit;
  final String? userId;
  final ContactType? contactType;
  final String? password; // ← ADD THIS

  const OtpVerificationPage({
    Key? key,
    required this.phoneNumber,
    this.title,
    this.subtitle,
    this.nextRoute,
    this.isPasswordReset = false,
    this.cubit,
    this.userId,
    this.contactType,
    this.password, // ← ADD THIS
  }) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  TextEditingController? _otpController;
  FocusNode? _pinFocusNode;
  StreamController<ErrorAnimationType>? _errorController;
  bool _hasError = false;
  String _currentOtp = '';
  bool _isNavigating = false;
  bool _isDisposed = false;

  bool get isProfileUpdate => widget.cubit != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _pinFocusNode?.requestFocus();
      }
    });
  }

  void _initializeControllers() {
    _otpController = TextEditingController();
    _pinFocusNode = FocusNode();
    _errorController = StreamController<ErrorAnimationType>();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _errorController?.close();
    try {
      _pinFocusNode?.dispose();
    } catch (e) {
      debugPrint('⚠️ FocusNode error on dispose: $e');
    }
    try {
      _otpController?.dispose();
    } catch (e) {
      debugPrint('⚠️ OTP Controller error on dispose: $e');
    }
    _pinFocusNode = null;
    _otpController = null;
    _errorController = null;
    super.dispose();
  }

  void _verifyOtp() {
    if (_isDisposed) return;
    if (_currentOtp.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan masukkan kode OTP'),
            backgroundColor: AppColors.primaryColor,
          ),
        );
      }
      return;
    }

    print('🔄 Verifying OTP: $_currentOtp for ${widget.phoneNumber}');

    if (isProfileUpdate) {
      // For profile updates, navigate to completion page
      if (mounted && widget.nextRoute != null) {
        context.pushNamed(
          widget.nextRoute!,
          extra: {
            'userId': widget.userId,
            'newValue': widget.phoneNumber,
            'verificationCode': _currentOtp,
            'type': widget.contactType,
            'cubit': widget.cubit,
          },
        );
      }
    } else {
      // For auth flow, use AuthBloc
      if (mounted) {
        context.read<AuthBloc>().add(
          VerifyOtpEvent(widget.phoneNumber, _currentOtp),
        );
      }
    }
  }

  void _resendOtp() {
  if (_isDisposed) return;
  if (mounted) {
    setState(() {
      _hasError = false;
      _currentOtp = '';
    });
    _otpController?.clear();
    print('🔄 Resending OTP for ${widget.phoneNumber}');

    if (isProfileUpdate) {
      // For profile updates, resend via cubit with password
      if (widget.contactType == ContactType.phone) {
        widget.cubit?.requestPhoneUpdate(
          userId: widget.userId!,
          newPhone: widget.phoneNumber,
          password: widget.password ?? '', // ← USE STORED PASSWORD
        );
      } else {
        widget.cubit?.requestEmailUpdate(
          userId: widget.userId!,
          newEmail: widget.phoneNumber,
          password: widget.password ?? '', // ← USE STORED PASSWORD
        );
      }
    } else {
      // For auth flow, use AuthBloc
      context.read<AuthBloc>().add(RequestOtpEvent(widget.phoneNumber));
    }

    context.read<OtpTimerBloc>().add(const StartOtpTimer(duration: 60));
  }
}
  void _showOtpError() {
    if (_isDisposed || !mounted) return;
    setState(() {
      _hasError = true;
    });
    _errorController?.add(ErrorAnimationType.shake);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted || _isDisposed) return;
      _otpController?.clear();
      setState(() {
        _currentOtp = '';
      });
    });
  }

  void _handleBack() {
    if (_isDisposed || _isNavigating) return;
    if (mounted) {
      context.read<OtpTimerBloc>().add(ResetOtpTimer());
      if (!isProfileUpdate) {
        context.read<AuthBloc>().add(ResetAuthEvent());
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed ||
        _otpController == null ||
        _pinFocusNode == null ||
        _errorController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(153),
          child: AppBar(
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: IconButton(
                icon: const Icon(
                  FontAwesomeIcons.arrowLeft,
                  color: AppColors.whiteColor,
                ),
                onPressed: _handleBack,
              ),
            ),
            flexibleSpace: SafeArea(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 70, 20, 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title ?? 'Verifikasi Akun',
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle ?? 'Masukkan kode OTP',
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: isProfileUpdate ? _buildProfileUpdateBody() : _buildAuthBody(),
      ),
    );
  }

  Widget _buildAuthBody() {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpVerificationSuccess) {
          if (_isNavigating || _isDisposed) return;
          _isNavigating = true;

          print('✅ OTP Verified Successfully for ${widget.phoneNumber}');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ OTP berhasil diverifikasi!'),
              backgroundColor: Colors.green,
            ),
          );

          context.read<OtpTimerBloc>().add(ResetOtpTimer());

          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted || _isDisposed) return;
            _isNavigating = false;

            if (widget.nextRoute != null) {
              if (widget.isPasswordReset) {
                context.pushNamed(
                  widget.nextRoute!,
                  extra: {'phone': widget.phoneNumber},
                );
              } else {
                context.pushNamed(widget.nextRoute!, extra: widget.phoneNumber);
              }
            } else {
              context.pushNamed('registerForm', extra: widget.phoneNumber);
            }
          });
        } else if (state is OtpVerificationError) {
          print('❌ OTP Verification Failed: ${state.message}');
          _showOtpError();
        } else if (state is OtpRequestSuccess) {
          print('📱 New OTP sent: ${state.otp}');
          if (mounted && !_isDisposed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('📱 Kode OTP baru: ${state.otp}'),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      },
      child: _buildOtpBody(),
    );
  }

  Widget _buildProfileUpdateBody() {
    return BlocProvider.value(
      value: widget.cubit!,
      child: BlocListener<ProfileUpdateCubit, ProfileUpdateState>(
        listener: (context, state) {
          if (state is ProfileUpdateAwaitingVerification) {
            if (mounted && !_isDisposed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.blue,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        },
        child: _buildOtpBody(),
      ),
    );
  }

  Widget _buildOtpBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: PinCodeTextField(
                    enabled: !_isNavigating && !_isDisposed,
                    appContext: context,
                    length: 6,
                    controller: _otpController!,
                    focusNode: _pinFocusNode!,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    autoFocus: false,
                    errorAnimationController: _errorController!,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.primaryFont,
                    ),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 56,
                      fieldWidth: 56,
                      fieldOuterPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      activeFillColor: AppColors.whiteColor,
                      activeColor: const Color(0xFF2196F3),
                      activeBorderWidth: 2,
                      selectedFillColor: AppColors.whiteColor,
                      selectedColor: const Color(0xFF2196F3),
                      selectedBorderWidth: 2,
                      inactiveFillColor: Colors.grey[100],
                      inactiveColor: AppColors.grayColor.withOpacity(0.3),
                      inactiveBorderWidth: 1.5,
                      errorBorderColor: AppColors.primaryColor,
                      errorBorderWidth: 2,
                    ),
                    onChanged: (value) {
                      if (_isDisposed) return;
                      if (_hasError && value.isNotEmpty && mounted) {
                        setState(() {
                          _hasError = false;
                        });
                      }
                      if (mounted) {
                        setState(() {
                          _currentOtp = value;
                        });
                      }
                    },
                    onCompleted: (value) {
                      print('OTP completed: $value');
                    },
                    beforeTextPaste: (text) {
                      return text?.contains(RegExp(r'^[0-9]+$')) ?? false;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedOpacity(
                  opacity: _hasError ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'OTP salah !',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildResendSection(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: (_isNavigating || _isDisposed) ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              foregroundColor: AppColors.blackColor,
              disabledBackgroundColor: Colors.grey[300],
              minimumSize: const Size(double.infinity, 56),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Selanjutnya',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResendSection() {
    if (_isDisposed) return const SizedBox.shrink();
    return BlocBuilder<OtpTimerBloc, OtpTimerState>(
      builder: (context, timerState) {
        if (timerState is OtpTimerRunning) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tidak dapat kode ?',
                    style: TextStyle(fontSize: 14, color: AppColors.grayColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kirim ulang dalam ${timerState.formattedTime}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grayColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (timerState is OtpTimerCompleted ||
            timerState is OtpTimerInitial) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tidak dapat kode ?',
                    style: TextStyle(fontSize: 14, color: AppColors.grayColor),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _resendOtp,
                    child: const Text(
                      'Kirim Ulang Kode',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}